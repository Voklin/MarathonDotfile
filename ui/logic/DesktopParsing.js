.pragma library

function terseFields(line) {
    var fields = [], field = "", escaped = false
    for (var i = 0; i < line.length; ++i) {
        var c = line[i]
        if (escaped) { field += c; escaped = false }
        else if (c === "\\") escaped = true
        else if (c === ":") { fields.push(field); field = "" }
        else field += c
    }
    if (escaped) field += "\\"
    fields.push(field)
    return fields
}
function nameAvailable(code, text) {
    return code === 0 && String(text).trim() === "b false"
}
function canSuspend(code, text) {
    return code === 0 && /^s "(yes|challenge)"$/.test(String(text).trim())
}
