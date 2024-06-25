template = """
<!DOCTYPE html>
<html>
<head>
<title>single-instance https example</title>
</head>
<body>
<h3>you're using {scheme}</h3>
</body>
</html>
"""


def application(environ, start_response):
    response = template.format(scheme=environ['wsgi.url_scheme'])
    start_response(
        "200 OK", [("Content-Type", "text/html"), ("Content-Length", str(len(response)))]
    )
    return [response.encode('utf-8')]
