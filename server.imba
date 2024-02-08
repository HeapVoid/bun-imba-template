import fs from "fs"
import path from 'path'
import ansis from 'ansis'
import type { BuildConfig } from 'bun'
import { imbaPlugin, stats } from './plugin.ts'
import { watch } from "chokidar";

# color theme for terminal messages
const theme =
	count: ansis.fg(15).bold
	start: ansis.fg(252).bg(233)
	filedir: ansis.fg(15)
	success: ansis.fg(40)
	failure: ansis.fg(196)
	time: ansis.fg(41)
	link: ansis.fg(15) # .underline
	online: ansis.fg(40).bg(22)
	
# ---------------------------------------------------------------
# Function to bundle imba files into js from the given entrypoint
# ---------------------------------------------------------------
export def bundle options = {}

	if !options.entrypoints[0]
		console.log theme.failure('Error.') + " No {theme.filedir("entrypoint")} is specified!"
		process.exit(0)
	elif !fs.existsSync(options.entrypoints[0])
		console.log theme.failure('Error.') + " The specified entrypoint does not exist: {theme.filedir(options.entrypoints[0])}"
		process.exit(0)
	elif !options.outdir
		console.log theme.failure('Error.') + " No {theme.filedir("output folder")} is specified!"
		process.exit(0)

	stats.failed = 0
	stats.compiled = 0
	stats.errors = 0
	stats.bundled = 0

	const start = Date.now();

	console.log("──────────────────────────────────────────────────────────────────────");
	console.log theme.start("Start building the Imba entrypoint{options.entrypoints.length > 1 ? 's' : ''}: {theme.filedir(options.entrypoints.join(','))}")
	
	# more on bun building params here: 
	# https://bun.sh/docs/bundler

	const result = await Bun.build
		entrypoints: options.entrypoints
		outdir: options.outdir
		target: options.target || 'node'
		sourcemap: options.sourcemap || 'none'
		minify: options.minify || true
		plugins: [imbaPlugin]
	
	if stats.failed
		console.log theme.start(theme.failure("Failure.") +" Imba compiler failed to proceed {theme.count("{stats.failed}")} file" + (stats.failed > 1 ? 's' : ''))
	else
		console.log theme.start(theme.success("Success.") +" It took {theme.time("{Date.now() - start}")} ms to bundle {theme.count("{stats.bundled}")} file{stats.bundled > 1 ? 's' : ''} to the folder: {theme.filedir("{options.outdir}")}")
	
	if !result.success and !stats.errors
		for log in result.logs
			console.log log

# ---------------------------------------------------------------------
# Function that monitors folder, bundles on change and serves via HTTP
# ---------------------------------------------------------------------
export def serve options = {source: '', public: '', entry: 'index.imba', port: 8080, chokidar: false, hmr: {favon: true, favicon: ''}}
	
	const entrypoint = options.source + options.entry

	# vaidate for folders and files needed for serving
	if !options.source
		console.log theme.failure('Error.') + " No {theme.filedir("source")} folder is specified!"
		process.exit(0)
	elif !fs.existsSync(options.source)
		console.log theme.failure('Error.') + " The specified source folder does not exist: {theme.filedir(options.source)}"
		process.exit(0)
	elif !options.public
		console.log theme.failure('Error.') + " No {theme.filedir("public")} folder is specified!"
		process.exit(0)
	elif !fs.existsSync(options.public)
		console.log theme.failure('Error.') + " The specified public folder does not exist: {theme.filedir(options.public)}"
		process.exit(0)
	elif !(await Bun.file(entrypoint).exists!)
		console.log theme.failure('Error.') + " The specified entrypoint does not exist: {theme.filedir("{entrypoint}")}"
		process.exit(0)

	# build the project sources
	const build\BuildConfig = {
		entrypoints: [entrypoint]
		outdir: options.public
		target: 'browser'
		minify: false
	}
	await bundle(build)

	# run http server to serve static files
	let clients\ServerWebSocket[] = []
	let hmr = ''
	if options.hmr.favicon
		hmr = (await Bun.file(import.meta.dir + '/hmr.html').text!)
			.replace('{{PORT}}', "{options.port}")
			.replace('{{FAV}}', "{options.hmr.favicon}")
			.replace('{{FAVON}}', "{options.hmr.favon}")

	Bun.serve
		port: options.port
		fetch: do(req, server)
			return if server.upgrade(req)
			const destination = new URL(req.url).pathname
			const path = options.public + (destination.length <= 1 ? '/index.html' : destination)
			const file = await Bun.file(path)
			if path.endsWith('index.html')
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

	console.log('')
	console.log(theme.online(" HTTP server is up and running: {theme.link("http://localhost:{options.port} ")}"))

	# watch for changes in the source folder
	let watcher\any
	const rebuild = do 
		await bundle(build)
		for client in clients
			client.send('reload')
	
	if options.chokidar
		watcher = watch(options.source, {
			ignored: /(^|[\/\\])\../
			persistent: true
			usePolling: true
			interval: 100
			depth: 5
			binaryInterval: 1300
		}).on('change', do rebuild!)

	else
		watcher = fs.watch(options.source, {recursive: true}, &) do(event, filename) rebuild!

	process.on "SIGINT", do
		watcher.close! if watcher and watcher.close isa Function
		process.exit(0)


