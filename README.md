#Rikulo UXL

[Rikulo UXL](http://rikulo.org) (User-interface eXtensible language) is a markup language for describing applications' user interfaces. UXL is a simple variant of XML. It allows you to define user interfaces in a similar manner to authoring HTML and XML pages. It also allows you to use the Model-View-Controller (MVC) pattern to develop applications.

* [Home](http://rikulo.org)
* [UXL Documentation](http://docs.rikulo.org/rikulo/latest/UXL)
* [UXL API Reference](http://api.rikulo.org/uxl/latest/)
* [Discussion](http://stackoverflow.com/questions/tagged/rikulo)
* [Issues](https://github.com/rikulo/uxl/issues)

Rikulo UXL is distributed under the Apache 2.0 License.

##Install from Dart Pub Repository

Add this to your `pubspec.yaml` (or create it):

    dependencies:
      rikulo_uxl:

Then run the [Pub Package Manager](http://pub.dartlang.org/doc) (comes with the Dart SDK):

    pub install

##Install from Github for Bleeding Edge Stuff

To install stuff that is still in development, add this to your `pubspec.yam`:

    dependencies:
      rikulo_uxl:
        git: git://github.com/rikulo/uxl.git

For more information, please refer to [Pub: Dependencies](http://pub.dartlang.org/doc/pubspec.html#dependencies).

##Usage

First, you have to prepare UXL files defining the user interface. Next, there are two ways to compile it into dart files: automatic building with Dart Editor or manual compiling.

###Build with Dart Editor

To compile your UXL files automatically, you just need to add a build.dart file in the root directory of your project, with the following content:

	import 'package:rikulo_uxl/compile.dart';
	void main() {
		build(new Options().arguments);
	}

With this build.dart script, whenever your UXL is modified, it will be re-compiled.

###Compile Manually

To compile a UXL file manually, run `uc` (UXL compiler) to compile it into the dart file with [command line interface](http://en.wikipedia.org/wiki/Command-line_interface) as follows:

    dart bin/uc.dart your-uxl-file(s)

A dart file is generated for each UXL file you gave.

###UXL and Its Generated Dart File

A UXL file can define one or multiple templates. For example, here is a UXL file defining a template called `ScrollViewTemplate`:

    <Template name="ScrollViewTemplate" args="rows: 30, cols: 30">
      <ScrollView class="scroll-view"
      profile="location: center center; width: 80%; height: 80%">
        <Apply forEach="r = 0; r < rows; ++r">
          <Apply forEach="c = 0; c < cols; ++c">
            <View style="border: 1px solid #553; background-color: ${CSS.color(250 - r * 4, 250 - c * 4, 200)}"
                left="${r * 50 + 2}" top="${c * 50 + 2}"
                width="${46}" height="${46}">
            </View>
          </Apply>
        </Apply>
      </ScrollView>
    </Template>

A template is actually compiled to a Dart function with the name specified in UXL:

    List<View> ScrollViewTemplate({parent, rows: 30, cols: 30}) {
      List<View> _vcr_ = new List();
      var _this_;

      final _v0_ = _this_ = new ScrollView()
      ...
      _vcr_.add(_v0_);
      ...
      return _vcr_;
    }

> For a complete dart file, please refer to [here](https://github.com/rikulo/uxl/blob/master/example/scroll-view/ScrollView.uxl.dart).

Having you UXL compiled, you can instantiate views based on the template whatever you want:

    void main() {
      final View mainView = new View()..addToDocument();
      ScrollViewTemplate(parent: mainView);
    }

##Pros and Cons

###Pros

* The user interface can be defined easily in a similar manner to HTML and XML pages.
* MVC/MVP and data-binding for improving the separation of view, model and controller.
* Performance is as good as expressing in Dart.
* Easy to debug since the generated Dart code is easy to understand.

###Cons

* It has to be compiled to Dart in advance.

> Unlike [Rikulo EUL](https://github.com/rikulo/eul), UXL has to be compiled to Dart. Performance is better and it is easier to debug.

##Notes to Contributors

###Create Addons

Rikulo is easy to extend. The simplest way to enhance Rikulo is to [create a new repository](https://help.github.com/articles/create-a-repo) and add your own great widgets and libraries to it.

###Fork Rikulo UXL

If you'd like to contribute back to the core, you can [fork this repository](https://help.github.com/articles/fork-a-repo) and send us a pull request, when it is ready.

Please be aware that one of Rikulo's design goals is to keep the sphere of API as neat and consistency as possible. Strong enhancement always demands greater consensus.

If you are new to Git or GitHub, please read [this guide](https://help.github.com/) first.
