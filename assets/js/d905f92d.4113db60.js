"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[533],{68144:e=>{e.exports=JSON.parse('{"functions":[{"name":"__call","desc":"The initiator/constructor of a Richify object.\\n```lua\\nlocal result: {string: string} = richify \\"hello world\\" {0, 5} \\"stroke\\"(Color3.new(1, 0, 0))\\n--or non-fusion-style:\\nlocal result: {string: string} = richify(\\"hello world\\")({0, 5})(\\"stroke\\")(Color3.new(1, 0, 0))\\n```","params":[],"returns":[],"function_type":"static","source":{"line":95,"path":"src/Richify/Richify.luau"}},{"name":"__call","desc":"Richify only has one method which is calling the Richify object.\\n```lua\\n--                                \\\\/(create object)\\\\/   \\\\/edit section    \\nlocal result: {string: string} = richify \\"hello world\\" {0, 5} \\"stroke\\"(Color3.new(1, 0, 0))\\n--or non-fusion-style:                                          /\\\\ edit stroke with /\\\\ the color of Red\\nlocal result: {string: string} = richify(\\"hello world\\")({0, 5})(\\"stroke\\")(Color3.new(1, 0, 0))\\n```\\n\\n| InputType | Description | Next Parameters\\n| -- | -- | -- |\\n| {number} | Edit a section of the string | none |\\n| \\"color\\" | Edit the color of the section | (color: Color3) |\\n| \\"size\\" | Edit the font size of the section | (size: number) |\\n| \\"stroke\\" | Edit the stroke of the section | (color: Color3, joins: string, thickness: number, transparency: number) |\\n| \\"insert\\" | Insert a string at a specific spot | {[1]: number, [2]: string} |\\n| (any rich text tag or shortened tag) | Add a rich text tag to the section | none |","params":[],"returns":[],"function_type":"static","source":{"line":125,"path":"src/Richify/Richify.luau"}}],"properties":[],"types":[{"name":"{string:","desc":"The type for the richify object after initializing one with a string.","lua_type":"string,__call: (InputType) -> Richify}","source":{"line":22,"path":"src/Richify/Richify.luau"}},{"name":"Custom","desc":"Just some shortened tag names for ease of use.","lua_type":"Tags","source":{"line":33,"path":"src/Richify/Richify.luau"}}],"name":"Richify","desc":"A rich-text customizer library.\\nTo see all the rich-text tags [here](https://create.roblox.com/docs/ui/rich-text).\\n\\n:::warning\\nThis library does have some problems and only works in some specific cases, wouldn\'t recommend using it for now. If I can fix/improve this in the future I will remove this warning.\\n:::","source":{"line":11,"path":"src/Richify/Richify.luau"}}')}}]);