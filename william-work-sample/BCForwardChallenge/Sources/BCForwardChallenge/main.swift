print("starting program luke")
guard CommandLine.arguments.count > 1 else {
    fatalError("This tool requires a filename as an argument")
    }
let fileName = CommandLine.arguments[1]
var contents = ""
do {
    contents = try String(contentsOfFile: fileName)
} catch {
    print("No file found with name \(fileName). \nError: \(error)")
}
let dl = DataRequest(data: contents)
let bl = Report(dataRequest: dl)
bl.test()
