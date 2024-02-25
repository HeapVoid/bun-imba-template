# bun-imba-template

This template uses [Bimba](https://github.com/HeapVoid/bimba) CLI tool to show how easily frontend could be developed with [Imba](https://imba.io) under [Bun](https://bun.sh). The speed and overall experience is marvelous.

Install Bun. Though at the moment it does not natively run under Windows, it works well under WSL. I use Windows myself and I like using Bun.

Clone this project and install project dependecies (there are only two of them: Imba and tiny Bimba-cli): 

```bash
bun install
```

Run the project:
```bash
bun dev
```

Initially I have implemented the live reload functionality, but then decided to refuse it. There is a pretty good VS Code extension: [Lite Server](https://marketplace.visualstudio.com/items?itemName=ritwickdey.LiveServer). It does everything needed out of the box.

Just let bimba rebuild the sources on change and Lite Server will reload the page in the browser.

PS. For me it takes less than 50ms to see the updates in the browser after saving the file (including compilation). 