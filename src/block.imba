
const files = 
	bun: 'assets/bun_logo.svg'
	imba: 'assets/imba_logo.svg'

export tag Block
	<self>
		css bgc:blue4
		<div>		
			css d:hflex h:100% ai:center jc:space-around
			<img src=files.imba>
				css w:clamp(100px, 30%, 300px) aspect-ratio:1
			<p> "+"
				css fs:clamp(20px, 20vw, 200px) fw:900 c:white ff: "Montserrat"
			<img src=files.bun>
				css w:clamp(100px, 30%, 300px) aspect-ratio: 80 / 70

		