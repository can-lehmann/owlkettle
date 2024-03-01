# MIT License
# 
# Copyright (c) 2022 Can Joshua Lehmann
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

import owlkettle, owlkettle/[playground, adw]
import std/options

viewable App:
  discard

method view(app: AppState): Widget =
  result = gui:
    Window:
      title = "About Dialog Example"
      defaultSize = (400, 200)
      
      HeaderBar {.addTitlebar.}:
        Button {.addLeft.}:
          text = "About"
          style = [ButtonSuggested]
          proc clicked() =
            discard app.open: gui:
              AboutWindow:
                applicationName = "My Application"
                developerName = "Erika Mustermann"
                version = "1.0.0"
                applicationIcon = "application-x-executable"
                supportUrl = "https://github.com/can-lehmann/owlkettle/discussions"
                issueUrl = "https://github.com/can-lehmann/owlkettle/issues"
                website = "https://can-lehmann.github.io/owlkettle/README"
                links = @{
                  "Tutorial": "https://can-lehmann.github.io/owlkettle/docs/tutorial.html",
                  "Installation": "https://can-lehmann.github.io/owlkettle/docs/installation.html"
                }
                comments = """My Application demonstrates the use of the Adwaita AboutWindow. Comments will be shown on the Details page, above links. <i>Unlike</i> GtkAboutDialog comments, this string can be long and detailed.It can also contain <a href='https://docs.gtk.org/Pango/pango_markup.html'>links</a> and <b>Pango markup</b>."""
                credits = @{
                  "Shaders": @[
                    "Erika Mustermann",
                    "Max Mustermann",
                  ],
                  "Sounds": @["Max Mustermann"]
                }
                acknowledgements = @{
                  "Special thanks to": @[
                    "My cat", "The Owlkettle Project https://github.com/can-lehmann/owlkettle"
                    ]
                }
                developers = @[
                  "Edgar Allan Poe <edgar@poe.com>",
                  "Erica Mustermann <erica@mustermann.com>",
                  "John Doe <john@doe.com>"
                  ]
                designers  = @["Dee Signer https://dee.si.gner/portfolio"]
                documenters = @["Dokju Mentar"]
                debugInfo = "Please attach the logs from <some directory> when reporting errors."
                copyright = "Erika Mustermann"
                licenseType = LICENSE_ARTISTIC # or set a custom license text via the `license` property
                legalSections = @[
                  LegalSection(
                    title: "Copyright and a known license",
                    copyright: some("© 2022 Example"),
                    licenseType: LICENSE_LGPL_2_1
                  ),
                  LegalSection(
                    title: "Copyright and custom license",
                    copyright: some("© 2022 Example"),
                    licenseType: LICENSE_CUSTOM,
                    license: some("Custom license text")
                  ),
                  LegalSection(
                    title: "Copyright only",
                    copyright: some("© 2022 Example"),
                    licenseType: LICENSE_UNKNOWN
                  ),
                  LegalSection(
                    title: "Custom license only",
                    licenseType: LICENSE_CUSTOM,
                    license: some("Something completely custom here.")
                  )
                ]
                releaseNotes = """
<p>Lorem ipsum</p>
<ul>
<li>Autem accusantium ut earum</li>
<li>Illum laboriosam ab ea explicabo aut perspiciatis.</li>
<li>Fuga commodi reiciendis unde officia neque est aut. Quisquam nostrum reiciendis explicabo sunt distinctio temporibus blanditiis. Quia quidem deleniti omnis.</li>
</ul>
                """

adw.brew(gui(App()))
