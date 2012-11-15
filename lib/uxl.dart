//Copyright (C) 2012 Potix Corporation. All Rights Reserved.
//History: Tue, Nov 13, 2012  5:37:58 PM
// Author: tomyeh
library rikulo_uxl;

import "package:rikulo/view.dart";
import "package:rikulo/event.dart" show ViewEvent;
import "package:rikulo/layout.dart" show layoutManager;

/** The template function of a control.
 */
typedef List<View> ControlTemplate({View parent, View beforeChild});

/**
 * The control used in UXL Model-View-Control (MVC) design pattern.
 * Every control that can be assigned to the control attribute must extend from
 * this class.
 *
 * ##Automatically Re-rendering
 *
 * Each command bound by the `on` attribute will invoke [onCommand] after
 * the given method (aka., the command handler) has been called.
 * By default, [onCommand] will invoke [render]
 * to re-instantiate the view ([view]) and all of its descendant views.
 *
 * In other words, you don't have to worry how to synchronize the change back to UI.
 * You need to modify the model as you want in the command handler. UI will be
 * re-rendered to reflect the latest states.
 *
 * However, you might prefer to alter the UI the way you want.
 * For example, some command won't change the UI at all, and some command
 * might just change a small part of UI. To do so, you have to override [onCommand]
 * to call [render] only really necessary.
 *
 * ##onRender callback
 *
 * When the view ([view]) and all of its descendant views are instantiated,
 * [onRender] will be called. You can override it to initialize UI if necessary.
 */
class Control {
  /** The view associated with this controller.
   *
   * This field will be assigned right after the constructor is called.
   * Each time [render] is called, this field will be updated with the view
   * being instantiated.
   */
  View view;
  /** The template associated with this controller.
   *
   * The instantiation of the views are actually done by calling
   * this method.
   *
   * > The template always returns a single-element list.
   *
   * This field will be assigned right after the constructor is called.
   */
  ControlTemplate template;

  /** Re-render the view (and all of its child views).
   * It first creates the view with [template], and then replaces [view].
   * Finally, invoke [onRender]
   */
  void render() {
    final parent = view.parent;
    if (parent == null) {
      final parentNode = view.node.parent, nextNode = view.node.nextNode;

      view.remove();
      view = null; //clear first, so template will assign to it
      template()[0];

      if (parentNode != null)
        view.addToDocument(ref: nextNode != null ? nextNode: parentNode,
          mode: nextNode != null ? "before": "child");
    } else {
      final next = view.nextSibling;

      view.remove();
      view = null; //clear first, so template will assign to it
      template(parent: parent, beforeChild: next)[0];

      parent.requestLayout();
    }

    onRender();
    layoutManager.flush(); //immediate for better responsive
  }

  /** Called after a command is received and processed by the command handler.
   *
   * Default: it invokes [render] to render the view ([view]) and all of its
   * descendant views. It is convenient, but, for better performance (if UI is
   * complicated), you can override this method not to re-render and alter UI
   * manually.
   *
   * For example,
   *
   *     void onCommand(String command, [ViewEvent event]) {
   *       //does nothing
   *     }
   *     void delete(ViewEvent event) {
   *       model.delete(something);
   *       view.query("#foo").... //update only the part of UI being affected
   *     }
   */
  void onCommand(String command, [ViewEvent event]) => render();
  /** Called after [view] and all children (defined in [template]) are instantiated.
   *
   * Default: does nothing. You can override it to handle the views if necessary.
   * For example, you can register event listeners, assign values and so on, though
   * they are generally done by using *command binding* and *data binding*.
   */
  void onRender() {
  }
}
