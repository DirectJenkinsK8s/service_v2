import click
from base import create_app_wsgi
from flask.cli import FlaskGroup


@click.group(cls=FlaskGroup, create_app=create_app_wsgi)
def main():
    """Management script for the service_v2 application."""


if __name__ == "__main__":  # pragma: no cover
    main()
