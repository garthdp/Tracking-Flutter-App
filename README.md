# Tracking app Assessment 
### By Garth du Preez 


## Disclaimer 
For the assessment I used both AI and Videos. I used AI for help making 
the UI because I was not familiar with using flutter. I used youtube videos 
for help with setting up the SQLite database and some of the google maps 
functionality. Lastly I wasn’t able to make it work when the app is 
minimised. 


## Homepage 
![Screenshot 2025-04-17 134356](https://github.com/user-attachments/assets/e8a79f48-4baf-4542-af17-2116b3cf0ee6)

The home page consists of three components, that being the map, the 
users position on the map using a blue pin, a button called “View Saved 
Routes” and another called “Start Tracking”.  


## Tracking Function 
![Screenshot 2025-04-17 134834](https://github.com/user-attachments/assets/96d62c53-c06d-4cc8-93fa-0a7f13e23a4d)
![Screenshot 2025-04-17 134850](https://github.com/user-attachments/assets/0e6b5529-b7cf-44cf-bda3-c8c53ab8a6db)

When the user clicks “Start tracking” the map will place a green pin 
showing where the user started tracking, “Start Tracking” will also change 
to “Stop Tracking”. The previous blue marker will be replaced with a red 
marker showing that the user is currently tracking and when the user clicks 
“Stop Tracking” the red marker will then indicate where the user finished, 
and a dialog box will prompt asking the user to save a name to the route. If 
they enter a name and save it will save the route to the SQLite database 
and if they click cancel it will not save and clear the route from the map. 


## Saved Routes 
![Screenshot 2025-04-17 135400](https://github.com/user-attachments/assets/96b04a17-8e2b-4241-a77f-06d3798ef76d)
![Screenshot 2025-04-17 135438](https://github.com/user-attachments/assets/791d96c7-befa-417a-b086-cc3f8f324f3a)


When clicking on “View Saved Routes” it will show a pop up box displaying 
a list of all the users saved routes, when the user clicks on a route it will 
then pan the map to show the route on the map. To clear the route the user 
can select another or when they start tracking it will also clear the route. 
