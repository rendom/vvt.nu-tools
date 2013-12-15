#Author: vvt.nu
import sublime, sublime_plugin, re, json,sys

PY3 = sys.version > '3'
if PY3:
    import urllib.request as urllib
else:
    import urllib2 as urllib

class VvtpasteCommand(sublime_plugin.TextCommand):
	def run(self, edit):
		sel = self.view.sel()[0]
		if sel:
			code = self.view.substr(self.view.sel()[0]); #.encode('utf8')
			data = json.dumps({"code": code}).encode('utf-8')
		else:
			code = self.view.substr(sublime.Region(0, self.view.size()))
			data = json.dumps({"code": code}).encode('utf-8')

		request = urllib.Request("https://vvt.nu/api/pastebin.json")
		request.add_header('Content-Type', 'application/json')
		request.add_data(data)
		req = urllib.urlopen(request)
		response = req.read().decode('utf-8')

		if not re.match("https", response):
			sublime.status_message("Something went wrong.")
		else:
			sublime.set_clipboard(response)
			sublime.status_message("Ctrl+v = "+response)
