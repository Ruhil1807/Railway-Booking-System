<%@ page isErrorPage="true" %>
<html>
<head><title>Error</title></head>
<body>
  <h2>Oops! Something went wrong.</h2>
  <p><%= request.getAttribute("error") %></p>
  <a href="index.html">Back to Home</a>
</body>
</html>
