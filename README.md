# rails-critical-css

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=flat-square)](https://opensource.org/licenses/MIT)
![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/mati365/rails-critical-css?style=flat-square)
![GitHub issues](https://img.shields.io/github/issues/mati365/rails-critical-css?style=flat-square)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](http://makeapullrequest.com)

Generate on demand critical css for route actions with minimum effort. It is pretty similar to other rails critical css gems but instead of pregenerating critical css in separate task this gem generates them in fly, dynamically and allows to prepend custom SCSS files to generated critical bundle.

## Installation

Be sure that NPM and Node is installed in your system and add to Gemfile:

```bash
gem 'rails_critical_css'
```

## Usage

Install `penthouse` NPM package in your project. Be sure that node_modules/ directory is present on production builds.

In initializer:

```ruby
RailsCriticalCss.config do |c|
  c.keep_larger_media_queries = true
  c.height = 19999 # prevent CLS on for example footer
end
```

In controller:

```ruby
  class ExampleController < ApplicationController
    action_critical_css :show, cache_key: :critical_css_cache_key
    # or
    action_critical_css :show, cache_key: -> { 'cache_key' }
    # or
    action_critical_css :show, cache_key: 'cache_key'

    ...

    def critical_css_cache_key
      "some-dynamic-key-#{random_variable}"
    end
  end
```

In template:

```slim
  # These files will be prepended to critical css generator output, it can be normal scss file from assets
  # critical_css_asset outputs nothing, it will be not appended to your html in link tag
  # (optional)
  = critical_css_asset 'some-file-to-be-prepended-to-criticals', critical: true
  = critical_css_asset 'hide-some-js-blocks', critical: true

  # depending on critical_css? flag (it returns false if critical css is being generated)
  # it emits link(href="your_file" rel="stylesheet") or link(href="your_file" rel="preload" onload="this.rel = 'stylesheet'")
  = critical_css_tag # emits inline critical CSS if present
  = critical_css_link 'css/vendors.css'
  = critical_css_link 'css/vendors.css', media: 'print'

  # If you have custom link helper (which for example loads css tag after GDPR accept) you can use helper below
  # Generator will extract hrefs from emitted html and generate stylesheet output
  # if critical css is compiled successfully it will emit critical css
  # and if preserve_content: true (which is default) arg is provided it will preserve provided content
  # (optional)
  = critical_css_tags
    = your_custom_link_helper "css/vendors.css"
    = your_custom_link_helper "css/app.css"

  - unless crticial_css?
    div Critical css is being generated...
```

## Testing

Enable redis caching on localhost and precompile locally assets. Critical CSS are generated using background job so they are injected to HTML after next requests (it takes around 3s)

## License

The MIT License (MIT)
Copyright (c) 2021 Mateusz Bagiński

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
