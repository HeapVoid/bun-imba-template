
# this tag is a converted tailwind component: 
# https://tailwindcomponents.com/component/slider-2

export tag Slider
	prop timer = 5000
	def slide
		const max = self.scrollWidth - self.clientWidth
		const left = max === self.scrollLeft ? 0 : self.clientWidth;
		self.scrollTo({ left, behavior: 'smooth' })
	def mount   do #interval = setInterval(slide.bind(self), timer)
	def unmount do clearInterval(#interval)

	<self#slider.h-screen.w-full.overflow-hidden.flex.flex-nowrap.text-center>
		<div.bg-teal-500.text-white.space-y-4.flex-none.w-full.flex.flex-col.items-center.justify-center>
			<h2.text-4xl.max-w-md> "Imba and Bun"
			<p.max-w-md> "They finally met. Now you can bundle your Imba server side or client side projects with Bun in milliseconds."
		<div.bg-blue-600.text-white.space-y-4.flex-none.w-full.flex.flex-col.items-center.justify-center>
			<h2.text-4xl.max-w-md> "Live reload"
			<p.max-w-md> "The client side project reacts immidiately to code updates. Favicon reflects the status of connection."
		<div.bg-pink-400.text-white.space-y-4.flex-none.w-full.flex.flex-col.items-center.justify-center>
			<h2.text-4xl.max-w-md> "New errors logging"
			<p.max-w-md> "The errors produced by Imba compiler are shown in terminal in a format that could be easily read."
		