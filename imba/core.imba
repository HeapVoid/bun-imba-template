import fs from "fs"
import ansis from 'ansis'
import type { BuildConfig } from 'bun'
import {imbaPlugin, stats} from './plugin.ts'

# ---------------------------------------------------------------
# Function to bundle imba files into js from the given entrypoint
# ---------------------------------------------------------------
export def bundle options\BuildConfig

	# more on bun building params here: https://bun.sh/docs/bundler
	const opts\BuildConfig =
		entrypoints: options.entrypoints || ['./src/index.imba']
		outdir: options.outdir || './public'
		target: options.target || 'node'
		sourcemap: options.sourcemap || 'none'
		minify: options.minify || true
		plugins: [imbaPlugin]

	# theme for terminal messages
	const theme =
		count: ansis.fg(15).bold
		start: ansis.fg(252).bg(233)
		filedir: ansis.fg(15)
		success: ansis.fg(40)
		failure: ansis.fg(196)
		time: ansis.fg(41)

	stats.failed = 0;
	stats.compiled = 0;
	const start = Date.now();

	console.log("──────────────────────────────────────────────────────────────────────");
	console.log theme.start("Start building the Imba entrypoint{opts.entrypoints.length > 1 ? 's' : ''}: {theme.filedir(opts.entrypoints.join(','))}")
	await Bun.build(opts)
	if stats.failed
		console.log theme.start(theme.failure("Failure.") +" Imba compiler failed to proceed {theme.count("{stats.failed}")} file" + (stats.failed > 1 ? 's' : ''))
	else
		console.log theme.start(theme.success("Success.") +" It took {theme.time("{Date.now() - start}")} ms to compile {theme.count("{stats.compiled + stats.failed}")} file{stats.compiled + stats.failed > 1 ? 's' : ''} to the folder: {theme.filedir("{opts.outdir}")}")



# ---------------------------------------------------------------------
# Function that monitors folder, bundles on change and serves via HTTP
# ---------------------------------------------------------------------
export def serve options = {source: '', public: '', entry: 'index.imba', port: 8080}

	# colortheme for terminal messages
	const theme =
		count: ansis.fg(15).bold
		start: ansis.fg(252).bg(233)
		filedir: ansis.fg(15)
		success: ansis.fg(40)
		failure: ansis.fg(196)
		time: ansis.fg(41)
		link: ansis.fg(40).underline

	# vaidate for folders and files needed for serving
	if !options.source
		console.log theme.failure('Error.') + " No {theme.filedir("source")} folder is specified!"
		process.exit(0)
	elif !fs.existsSync(options.source)
		console.log theme.failure('Error.') + " The specified source folder does not exist: {theme.filedir("source")}"
		process.exit(0)
	elif !options.public
		console.log theme.failure('Error.') + " No {theme.filedir("public")} folder is specified!"
		process.exit(0)
	elif !fs.existsSync(options.public)
		console.log theme.failure('Error.') + " The specified public folder does not exist: {theme.filedir("public")}"
		process.exit(0)
	elif !(await Bun.file(options.source+'/'+options.entry).exists!)
		console.log theme.failure('Error.') + " The specified entrypoint does not exist: {theme.filedir("{options.source+'/'+options.entry}")}"
		process.exit(0)

	# build the project sources
	const build\BuildConfig = {
		entrypoints: [options.source+'/'+options.entry]
		outdir: options.public
		target: 'browser'
		minify: false
	}
	await bundle(build)

	# run http server to serve static files
	let clients\ServerWebSocket[] = []
	let hmr = (await Bun.file('./imba/hmr.html').text!).replace(/{{port}}/g, "{options.port}")

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

	# watch for changes in the source folder
	const srcpath = (Bun.main.match(/(.*)[\/\\]/)[1] || '') + options.source.slice(1)
	let watcher = fs.watch(srcpath, {recursive: true}, &) do(event, filename)
		await bundle(build)
		for client in clients
			client.send('reload')

	process.on "SIGINT", do
		watcher.close!
		process.exit(0)


