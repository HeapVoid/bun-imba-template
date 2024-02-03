import {watch} from "fs"
import ansis from 'ansis'
import {compile} from './compile.imba'
import type { BuildConfig } from 'bun'

# main project options
const options =
	public: './public'
	source: './src'
	entrypoint: 'index.imba'
	port: 8080

# theme for terminal messages
const theme =
	count: ansis.fg(15).bold
	start: ansis.fg(252).bg(233)
	filedir: ansis.fg(15)
	success: ansis.fg(40)
	failure: ansis.fg(196)
	time: ansis.fg(41)
	link: ansis.fg(40).underline

# ---------------------------------------
# build the project sources
# ---------------------------------------
const build\BuildConfig = {
	entrypoints: [options.source+'/'+options.entrypoint]
	outdir: options.public
	target: 'browser'
	minify: false
}
await compile(build)

# ---------------------------------------
# run http server to serve static files
# ---------------------------------------
let clients\ServerWebSocket[] = []
let hmr = (await Bun.file('./hmr.html').text!).replace(/{{port}}/g, "{options.port}")

Bun.serve
	port: options.port
	fetch: do(req, server)
		return if server.upgrade(req)
		const destination = new URL(req.url).pathname
		const path = options.public + (destination.length <= 2 ? '/index.html' : destination)
		const file = await Bun.file(path)
		if path.endsWith('.html')
			return new Response((await file.text!) + hmr, {status: 200, headers: {"Content-Type": "text/html;charset=utf-8"}})
		return new Response(file)
	error: do(err) return new Response(null, { status: 404 })
	websocket:
		open: do(ws) 
			clients.push ws
			return
		close: do(ws)
			let index
			for client, idx in clients when client is ws
				index = idx
			if index isa 'number'
				clients.splice(index, 1)
			return
		message: do(ws)
			return

console.log("──────────────────────────────────────────────────────────────────────");
console.log("HTTP server is up and running: {theme.link("http://localhost:{options.port}")}")

# ---------------------------------------
# watch for changes in the source folder
# ---------------------------------------
let watcher = watch(import.meta.dir + options.source.slice(1), {recursive: true}, &) do(event, filename) 
	console.log 
	await compile(build)
	for client in clients
		client.send('reload')

process.on "SIGINT", do
	watcher.close!
	process.exit(0)


