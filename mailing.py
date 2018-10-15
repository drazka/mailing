import csv
import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.base import MIMEBase
from email import encoders
import re
from email.mime.text import MIMEText

server = smtplib.SMTP('smtp.gmail.com:587')
server.starttls()
server.login('infoinvtr@gmail.com', 'password')
email_data = csv.reader(open('email.csv', 'r'))
email_pattern = re.compile("^.+@.+\..+$")


for row in email_data:
    if email_pattern.search(row[1]):

        msg = MIMEMultipart()
        msg['From'] = 'infoinvtr@gmail.com'
        body = 'my messydz'
        msg.attach(MIMEText(body, 'plain'))
        del msg['To']
        msg['To'] = row[1]
        msg['Subject'] = row[0]
        filename = row[2]
        attachment = open('data_atts/%s' % filename, 'rb')
        part = MIMEBase('application', 'octet-stream')
        part.set_payload((attachment).read())
        encoders.encode_base64(part)
        part.add_header('Content-Disposition', "attachment; filename= %s" % filename)

        msg.attach(part)
        try:
            server.sendmail('izabdr@gmail.com', [row[1]], msg.as_string())
        except smtplib.SMTPException:
            print('ups, sthg got wrong!')
server.quit()
