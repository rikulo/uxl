//Copyright (C) 2012 Potix Corporation. All Rights Reserved.
//History: Tue, Nov 13, 2012  5:37:58 PM
// Author: tomyeh
library rikulo_uxl;

import "package:rikulo/view.dart";
import "package:rikulo/event.dart" show ViewEvent;
import "package:rikulo/layout.dart" show layoutManager;

typedef List<View> ControlTemplate({View parent});

/**
 * The control used in UXL Model-View-Control (MVC) design pattern.
 * Every control that can be assigned to the control attribute must extend from
 * this class.
 *
 * ##Automatically Re-rendering
 *
 * ##onRender callback
 *
 */
class Control {
  /** The view associated with this controller.
   *
   * This field will be assigned right after the constructor is called.
   */
  View view;
  /** The template associated with this controller.
   *
   * The instantiation of the views are actually done by calling
   * this method:
   *
   *    View view = ctrl.template()[0];
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
      view = template()[0];

      if (parentNode != null)
        view.addToDocument(ref: nextNode != null ? nextNode: parentNode,
          mode: nextNode != null ? "before": "child");
    } else {
      final next = view.nextSibling;

      view.remove();
      view = template()[0];

      parent.addChild(view, next);
      parent.requestLayout();
    }

    onRender();
    layoutManager.flush(); //immediate for better responsive
  }

  /** Called after a command is received.
   *
   * Default: it invokes [render] to render all children.
   * To have better performance, you can override this method not to re-render.
   * For example,
   *
   *    void onCommand(String command, [View event]) {
   *    }
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
