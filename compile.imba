import {imbaPlugin, stats} from './preload.ts'
import type { BuildConfig } from 'bun'
import ansis from 'ansis'

export def compile options\BuildConfig

	# theme for terminal messages
	const theme =
		count: ansis.fg(15).bold
		start: ansis.fg(252).bg(233)
		filedir: ansis.fg(15)
		success: ansis.fg(40)
		failure: ansis.fg(196)
		time: ansis.fg(41)

	# more on bun building params here: https://bun.sh/docs/bundler
	const opts\BuildConfig =
		entrypoints: options.entrypoints || ['./src/index.imba']
		outdir: options.outdir || './public'
		target: options.target || 'node'
		sourcemap: options.sourcemap || 'none'
		minify: options.minify || true
		plugins: [imbaPlugin]

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