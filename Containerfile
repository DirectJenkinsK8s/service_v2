FROM python:3.11-alpine
COPY . /app
WORKDIR /app
RUN pip install .
RUN service_v2 create-db
RUN service_v2 populate-db
RUN service_v2 add-user -u admin -p admin
EXPOSE 5000
CMD ["project_name", "run"]
