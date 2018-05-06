# SAAOSX
A native user interface to the State Archives of Assyria online volumes

## WARNINGS
This application is in alpha and is deficient in important ways:
- Built on [CDKSwiftOracc](https://github.com/ckanchan/CDKSwiftOracc) which is also in alpha and has some bugs
- Uses [CDKOraccInterface](https://github.com/ckanchan/CDKOraccInterface) which relies on the Oracc JSON API, which doesn't work; or the Github API, which is rate-limited without an API key (not included)
- Parts of its functionality require SQL databases derived from the Oracc corpora which aren't included in the source repository.

## Introduction
This application provides a Mac native user interface to the [SAAo](http://oracc.org/saao/corpus) and [RINAP](http://oracc.org/rinap/corpus) text editions hosted on Oracc. 
This application also includes an iOS alpha interface.

## Copyrights and Licenses
See [CREDITS](CREDITS)


## Dependencies
This application depends on 
 - [SQLite.swift](https://github.com/stephencelis/SQLite.swift)
 - [ZIPFoundation](https://github.com/weichsel/ZIPFoundation)
 - [CDKSwiftOracc](https://github.com/ckanchan/CDKSwiftOracc)
 - [CDKOraccInterface](https://github.com/ckanchan/CDKOraccInterface)
