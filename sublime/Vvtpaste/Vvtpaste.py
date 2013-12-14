#Author: vvt.nu
import sublime, sublime_plugin, urllib, re, json

class VvtpasteCommand(sublime_plugin.TextCommand):
	def run(self, edit):
		sel = self.view.sel()[0]
		if sel:
			code = self.view.substr(self.view.sel()[0]).encode('utf8')
			data = json.dumps({"code": code, "hidden": 1, "name": "Anon"}).encode('utf-8')
		else:
			code = self.view.substr(sublime.Region(0, self.view.size())).encode('utf8')
			data = json.dumps({"code": code, "hidden": 1, "name": "Anon"}).encode('utf-8')

		headers = {}
		headers['Content-Type'] = 'application/json'
		req = urllib.urlopen("http://vvt.nu/api/pastebin.json", data, headers)
		response = req.read()

		if not re.match("http", response):
			sublime.status_message("Something went wrong.")
		else:
			sublime.set_clipboard(response)
			sublime.status_message("Ctrl+v = "+response)
		req.close()