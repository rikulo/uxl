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

then, a dart file is generated for each UXL file you gave.

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
