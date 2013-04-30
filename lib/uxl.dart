//Copyright (C) 2012 Potix Corporation. All Rights Reserved.
//History: Tue, Nov 13, 2012  5:37:58 PM
// Author: tomyeh
library rikulo_uxl;

import "package:rikulo_ui/view.dart";
import "package:rikulo_ui/event.dart" show ViewEvent;
import "package:rikulo_ui/layout.dart" show layoutManager;

/** The template function of a control.
 */
typedef List<View> ControlTemplate({View parent, View beforeChild});

/**
 * The control used in UXL Model-View-Control (MVC) design pattern.
 * Every control that can be assigned to the control attribute must extend from
 * this class.
 *
 * ##Alter Model and Update UI
 *
 * The simplest form of MVC is to make models as plain Dart objects, such as
 * a list of customers and so on. Then, in the command handlers of a control,
 * you can alert the model, and then update the UI accordingly.
 *
 * For example, you can alert the data and modify the UI directly in
 * a command handler as follows:
 *
 *     void delete(ViewEvent event) {
 *       model.delete(something);
 *       view.query("#foo").remove(); //update only the part of UI being affected
 *     }
 *
 * Alternatively, if there are a lot of views to modify,
 * you can invoke [render] to re-render the whole hierarchy of views
 * starting at [view] as follows:
 *
 *     void reload(ViewEvent event) {
 *       model.reload();
 *       render(); //re-render the view
 *     }
 *
 * ###Seperate Further with Model
 *
 * It is convenient to handle both model and UI in a command handler.
 * However, it also means, if you alter the model directly rather than invoke
 * the command handlers (such as in a timer), UI won't be updated.
 *
 * Rather than having all data modification going through the command handlers,
 * you can separate the coupling further as follows:
 *
 * 1. Use one of data models found in `package:rikulo_ui/model.dart` if appropriate.
 * Or, implement your model by extending from `DataModel` (in `package:rikulo_ui/model.dart`).
 * 2. Then, each method of the model that modifies the data (such as setters) shall
 * invoke `DataModel.sendEvent` to send a proper event to notify the changes.
 * 3. Finally, your control shall listen to these events that your model might
 * send, and alter the UI accordingly.
 *
 * For example,
 *
 *     class YourModel extends Model {
 *       void add(something) {
 *         ...//modify the model
 *         sendEvent(new YourDataEvent(this, 'add', something));
 *       }
 *     }
 *
 *     class YourControl extends Control {
 *       YourControl(YourModel model) {
 *         model.on.add.listen((YourDataEvent e) {
 *           ...//alter UI accordingly
 *         });
 *       }
 *       void add(e) {
 *         model.add(something);
 *         //no need to update UI here since the listener above will handle it
 *       }
 *     }
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
   * Finally, invoke [onRender].
   *
   * Notice it will invoke `parent.requestLayout(true)' automatically.
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

  /** Called after [view] and all children (defined in [template]) are instantiated.
   *
   * Default: does nothing. You can override it to handle the views if necessary.
   * For example, you can register event listeners, assign values and so on, though
   * they are generally done by using *command binding* and *data binding*.
   */
  void onRender() {
  }
}
