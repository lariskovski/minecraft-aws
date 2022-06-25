#!/usr/bin/python3 -u
from mcrcon import MCRcon
from time import sleep
from os import getenv
import requests

# RCON port not allowed on Security Group. Local access only.
RCON_ADDRESS="localhost"
RCON_PASSWORD="secretpassword"

GITHUB_USER=getenv("GITHUB_USER")
GITHUB_REPO=getenv("GITHUB_REPO")
GITHUB_AUTH_TOKEN=getenv("GITHUB_AUTH_TOKEN")

def trigger_destroy_workflow():
    hed = {'Authorization': 'Bearer ' + GITHUB_AUTH_TOKEN}
    data = {'event_type' : 'destroy'}
    url = f'https://api.github.com/repos/{GITHUB_USER}/{GITHUB_REPO}/dispatches'
    response = requests.post(url, json=data, headers=hed)

def get_int_from_str(string):
    # Get the output: There are 1 of a max of 20 players online: miner96
    # split into spaces get the thrid correspondence
    # which is the number of players online
    return int(string.split(" ")[2])

def execute_rcon_command(command):
    # Acutally makes the call to rcon
    mcr = MCRcon(RCON_ADDRESS, RCON_PASSWORD)
    mcr.connect()
    resp = mcr.command(command) # output: There are 1 of a max of 20 players online: miner96
    mcr.disconnect()
    return resp


def get_current_number_of_players():
    list_players = execute_rcon_command("/list")
    number_of_players = get_int_from_str(list_players)
    return number_of_players


def main():
    # Update current check
    number_of_players_current_check = get_current_number_of_players()

    if number_of_players_current_check == 0:
        print("Server is idle. Shutting down.")
        trigger_destroy_workflow()
        
    else:
        print(f"Server is not idle. Online players: {number_of_players_current_check}")

main()