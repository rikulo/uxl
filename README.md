#Rikulo UXL

[Rikulo UXL](http://rikulo.org) (User-interface eXtensible language) is a markup language allowing developers to define user-interfaces in XML.

Unlike [Rikulo EUL](https://github.com/rikulo/rikulo-eul), UXL has to be compiled to Dart. Performance is better and it is easier to debug.

* [Home](http://rikulo.org)
* [Documentation](http://docs.rikulo.org)
* [API Reference](http://api.rikulo.org/rikulo-uxl/latest/)
* [Discussion](http://stackoverflow.com/questions/tagged/rikulo)
* [Issues](https://github.com/rikulo/rikulo-uxl/issues)

Rikulo EUL is distributed under the Apache 2.0 License.

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
        git: git://github.com/rikulo/rikulo-uxl.git

For more information, please refer to [Pub: Dependencies](http://pub.dartlang.org/doc/pubspec.html#dependencies).

##Usage

    dart bin/uc.dart your-uxl-file(s)

then, a dart file is generated for each UXL file you gave. To generate a more readable file, you can specify the verbose option, `-v`:

    dart bin/uc.dart -v your-uxl-file(s)

For example, here is a UXL file defining a template called `ScrollViewTemplate`:

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

It will be compiled to a dart file containing a function called `ScrollViewTemplate`:

    List<View> ScrollViewTemplate({parent, rows: 30, cols: 30}) {
      List<View> _vcr_ = new List();
      var _this_;

      final _v0_ = _this_ = new ScrollView()
      ...
      _vcr_.add(_v0_);
      ...
      return _vcr_;
    }

> For a complete dart file, please refer to [here](https://github.com/rikulo/rikulo-uxl/blob/master/example/scroll-view/ScrollView.uxl.dart).

Then, you can instantiate views based on the template whatever you want:

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

##Notes to Contributors

###Create Addons

Rikulo is easy to extend. The simplest way to enhance Rikulo is to [create a new repository](https://help.github.com/articles/create-a-repo) and add your own great widgets and libraries to it.

###Fork Rikulo UXL

If you'd like to contribute back to the core, you can [fork this repository](https://help.github.com/articles/fork-a-repo) and send us a pull request, when it is ready.

Please be aware that one of Rikulo's design goals is to keep the sphere of API as neat and consistency as possible. Strong enhancement always demands greater consensus.

If you are new to Git or GitHub, please read [this guide](https://help.github.com/) first.
