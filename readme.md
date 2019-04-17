# Lua-OcrSpace
A lua wrapper to the ocrSpace api

## What it does?

This module adds a high level wrapper to the [ocrSpace api](https://ocr.space/).

```lua
local ocr = Ocr("apikey");
parsed_image = ocr:get("https://example.com/image.jpg")
print(img.ParsedResults[1].ParsedText)
```


## Installation and Usage

### Installing

```
luarocks install --server=http://luarocks.org/dev lua-ocrspace
```

```lua
local OcrSpace = require("ocrSpace")
```

### Usage
The wrapper allow you to Ocr images using get or post.
Get requests needs an url, post requests works with a url a image or a base64 image

#### Initializating
First you need get the API key, you can get one here on [Space api](https://ocr.space/ocrapi), the key will be sended to your e-mail
```lua
ocrSpace = OcrSpace("apikey")

```

#### Using GET
The imageURL it's a string to an image file.
```lua
function OcrSpace:get(url, options) -- returns a table
```
There are limitations to get info. Consult Space OCR api for informations about it.

#### Using POST 
You can make a POST request using a file or an url.
```lua
function OcrSpace:post(source, options) -- returns a table
```
The souce can be an url
```lua
local source = {url = "http://example.com/"}
```
A base64 iamge
```lua
local source = {base64Image = base64data} -- too big for a actual example, visit ocrSpace docs for more info
```
Or a file
```lua
--like this
local file = io.open("file.jpg", "rb")
local source = {file = file}
-- or like this
local content = file:read("*a")
source = {file = {name = "file.jpg", data = content}}

#### Using Base64
```go
func PostBase64(paramTexts Params, base64 string) (ProcessedDoc, error)
```

#### Another methods
You can also set the default settings to be used in requests with the set_default method
```lua
function OcrSpace:set_default(options) -- set the default table
```
And, similarly, you can get the current dafault
```lua
function OcrSpace:get_default() -- return the default table
```
### Tables
#### The following table are the tables that can be passed as default or on a specific request
```lua
    self.default = {
        url = default["url"],
        file = default["file"],
        base64Image = default["base64Image"],
        language =  default["language"] or "eng",
        isOverlayRequired = default["isOverlayRequired"],
        filetype = default["filetype"],
        detectOrientation = default["detectOrientation"],
        isCreateSearchablePdf = default["isCreateSearchablePdf"],
        isSearchablePdfHideTextLayer = default["isSearchablePdfHideTextLayer"],
        scale = default["scale"],
        isTable = default["isTable"]
    }
```

#### The requests will return the following table
```lua
result = {
        ParsedResults = {
            {
                TextOverlay = {
                    Lines = {
                        {
                            Words: [
                                {
                                WordText" = "Word 1",
                                Left = 106,
                                Top = 91,
                                Height = 9,
                                Width = 11
                                },
                                {
                                WordText = "Word 2",
                                Left = 121,
                                Top = 90,
                                Height = 13,
                                Width = 51
                                }
                            ],
                            MaxHeight = 13,
                            MinTop = 90
                        },
                    },
                HasOverlay = true,
                Message" = nil
                },
                FileParseExitCode = "1",
                ParsedText = "This is a sample parsed result",                
                ErrorMessage = nil,
                ErrorDetails = nil
            },
            {
                TextOverlay = null,
                FileParseExitCode" = -10,
                ParsedText = nil,
                                        
                ErrorMessage = "...error message (if any)",
                ErrorDetails = "...detailed error message (if any)"
            }
            },
        OCRExitCode = "2",
        IsErroredOnProcessing" = false,
        ErrorMessage = null,
        ErrorDetails = null
        SearchablePDFURL = "https://....." (if requested, otherwise null) 
        ProcessingTimeInMilliseconds = "3000"
    }
             
```

## Testing
The spec were made using the busted library
```lua
luarocks install busted
busted
```

## License
This software uses the MIT License.
