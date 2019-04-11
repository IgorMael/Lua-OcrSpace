local http = require("socket.http")
local ltn12 = require("ltn12")
local cjson = require("cjson")
local encode = (require "multipart-post").encode

local function get_type(source)
    local source_type
    local types = {"url", "file", "base64Image"}
    for _, value in ipairs(types) do
        if source[value] then
            if not source_type then source_type = value
            else error("A request can have only one type(url | file | base64Image)", 2)
            end
        end
    end
    return source_type
end

local OcrSpace = {}
OcrSpace.__index = OcrSpace
setmetatable(OcrSpace, {
    __call = function (cls, ...)
      return cls.new(...)
    end,
})

function OcrSpace.new(apiKey, default)
    if not apiKey then
        error("You must provide an apiKey", 2)
    end
    if type(apiKey) ~= "string" then
        error("The apikey must be a string", 2)
    end
    local self = setmetatable({}, OcrSpace)
    default = default or {}
    self.apikey = apiKey
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
    return self
end

function OcrSpace:set_default(options)
    for k,v in pairs(options) do
        self.default[k] = v
    end
end

function OcrSpace:get_default()
    return self.default
end

function OcrSpace:post(source, options)
    source = source or self.default["url"] or self.default["file"] or self.default["base64Image"]
    if not source then
        error("You should specify a url, file or base64Image", 2)
    end

    local req_body = {}
    for k,v in pairs(self.default) do
        req_body[k] = v
    end
    if options then
        for k,v in pairs(options) do
            req_body[k] = v
        end
    end

    local source_type = get_type(source)
    if source_type == "file" and type(source["file"]) == "userdata" then
        source["file"] = {name = "file.png", data = source["file"]:read("*a")}
    end
    req_body[source_type] = source[source_type]

    local form, boundary = encode(req_body)
    local header = {
        apikey = self.apikey,
        ["Content-Type"] = "multipart/form-data; charset=utf-8; boundary="..boundary,
        ["Content-Length"] = #form
    }

    local response_body = {}
    http.request{
        url = "https://api.ocr.space/parse/image",
        source = ltn12.source.string(form),
        sink = ltn12.sink.table(response_body),
        headers = header,
        method = "POST"
    }
    return cjson.decode(response_body[1])
end

function OcrSpace:get(imageUrl, options)
    if self.apikey == nil then
        error("apikey not provided. Initialize the library first")
    end
    options = options or {}
    local url = [[https://api.ocr.space/parse/imageurl?]]
    if not imageUrl or type(imageUrl) ~= "string" then
        error("source should be a string")
    end
    url = url .. "apikey=" .. "apikey=" .. self.apikey .. "&url=" .. imageUrl .. "&language=" .. (options["language"] or self.default["language"])
    if options["isOverlayRequired"] or self.default["isOverlayRequired"] then
        url = url .. "&isOverlayRequired=True"
    end
    local response_body = {}
    http.request{url = url,sink = ltn12.sink.table(response_body)}
    return cjson.decode(response_body[1])
end
return OcrSpace
