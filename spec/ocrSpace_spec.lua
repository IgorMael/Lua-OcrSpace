require("busted")
local Ocr = require("ocrSpace")
local http = require("socket.http")
local validApi = "d16ae8619488950" -- test apikey

describe("Lua OcrSpace unit testing", function()
    describe("Initialize the library", function()
        it("Should return an error if no apikey is passed", function()
            assert.has_error(Ocr, "You must provide an apiKey")
        end)
        it("Should return an error if the key isnt a string", function()
            local key = 123
            assert.has_error(function() return Ocr(key) end, "The apikey must be a string")
            local key = {apikey = "123"}
            assert.has_error(function() return Ocr(key) end, "The apikey must be a string")
            key = "arbitraryapikey"
            assert.has.no_error(function() return Ocr(key) end)
        end)
        it("Should set the apiKey on initalization", function()
            local ocr = Ocr("randomkey")
            assert.are.equal("randomkey", ocr["apikey"])
        end)
    end)
    describe("Make a get request", function ()
        it("Should return an error if no apikey is found", function()
            assert.has_error(function() return Ocr.get("http://www.google.com") end, "apikey not provided. Initialize the library first")
        end)
        it("Should return an error if no url is passed", function()
            local ocr = Ocr("abc")
            assert.has_error(function () return ocr:get() end, "source should be a string")
            assert.has_error(function () return ocr:get(123) end, "source should be a string")
            assert.has_error(function () return ocr:get({}) end, "source should be a string")
        end)
        it("Should return a table if a string is passed", function()
            local ocr = Ocr(validApi)
            assert.are.equals(type(ocr:get("http://example.com")), "table")
        end)
        -- it("Should add the options config", function()
        --     stub(http, "request")
        --     local url = "http://example.com"
        --     local options = {
        --         isOverlayRequired = true,
        --         isOverlayRequired = false
        --     }
        --     assert.stub(http.request).was.called_with({url = url,sink = ltn12.sink.table(response_body)})
        -- end)
    end)


end)