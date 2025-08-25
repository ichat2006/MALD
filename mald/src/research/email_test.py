import smtplib, ssl

port = 465  # For starttls
smtp_server = "******.gmail.com"
sender_email = "********@gmail.com"
receiver_email = "*******@gmail.com"
password = "Enter your password"
message = """\
Subject: Hi there

This message is sent from Python."""

context = ssl.create_default_context()
with smtplib.SMTP_SSL(smtp_server, port, context=context) as server:
    server.login(sender_email, password)
    server.sendmail(sender_email, receiver_email, message)
