# Contributing to Dixie

If you would like to contribute code you can do so through GitHub by forking the repository and sending a pull request.

When submitting code, please make every effort to follow existing conventions and style in order to keep the code as readable as possible.

## Pull requests
Before creating a pull request please make sure the following steps are completed:

* Make sure to update to the latest version of the master branch and branch out from that to avoid conflicts.
* Check that both the Dixie and DixieTests schemes compile successfully.
* Check that the unit tests included in the DixieTests scheme all execute successfully.
* Check that all use cases in the sample project using the modified version of Dixie are still functioning correctly.
* In the case of a new feature all the relevant use cases are covered with new unit tests.
* In the case of a bug fix a new unit test covers the use case, which should execute successfully with the fix in place.
* New files contain the common license header (please see below).
* New classes and methods contain enough documentation to understand their purpose.
* Please make sure the pull request contains a meaningful description explaining the problem the change solves and how the solution works.
* Please also check that the created pull request's state is green after the validation is completed by Travis CI.

## Issues
If you find a bug in the project (and you don’t know how to fix it), have trouble following the documentation or have a question about the project, then please create an issue! Some tips [from the GitHub Guide](https://guides.github.com/activities/contributing-to-open-source/):

* Please check existing issues for the problem you're seeing. Duplicating an issue is slower for both parties so search through open and closed issues to see if what you’re running in to has been addressed already.
* Be clear about what your problem is: what was the expected outcome, what happened instead? Detail how someone else can recreate the problem.
* Include system details like the browser, library or operating system you’re using and its version.
* Paste error output or logs in your issue or in a Gist. If pasting them in the issue, wrap it in three backticks: ``` so that it renders nicely.

## Contact
In case of major changes please feel free to reach out to the maintainers of the project at any time, so we can figure out the best approach together:

* Peter Wiesner (peter.wiesner@skyscanner.net, @WiesnerPeti)
* Zsolt Varnai (zsolt.varnai@skyscanner.net, @zsoltvarnai)
* Csaba Szabo (csaba.szabo@skyscanner.net, @CsabaSzabo)
* Zsombor Fuszenecker (zsombor.fuszenecker@skyscanner.net, @zsbee)

## License

By contributing your code, you agree to license your contribution under the terms of the APLv2: https://github.com/Skyscanner/Dixie/blob/master/LICENSE

All files are released with the Apache 2.0 license.

If you are adding a new file it should have a header like this:

```
//
// Dixie
// Copyright 2015 Skyscanner Limited
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
// You may obtain a copy of the License at:
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and limitations under the License.
```
