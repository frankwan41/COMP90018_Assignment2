# COMP90018_SoftwareProject-What2Eat
<p align="center">
<img src="readme_images/welcomeView.jpg" alt="Welcome View" width="400" height="400" align="center">
</p>

## Table of Contents

- [What2Eat](#comp90018_SoftwareProject-what2eat)
  - [Introduction](#introduction)
  - [Table of Contents](#table-of-contents)
  - [Demo Video](#demo-video)
  - [User Guide](#user-guide-and-key-features)
    - [Guest Mode](#guest-mode)
      - [Welcome](#welcome)
      - [Read Posts](#read-posts-as-a-guest-if-yes)
      - [Shake a Tag](#shake-a-kind-of-cuisine-if-no)
      - [Log In or Sign Up](#log-in-or-sign-up)
    - [User Mode](#user-mode)
      - [Like Post or Comment](#like-post-or-comment)
      - [Send or Delete Post](#send-or-delete-post)
      - [Send or Delete Comment](#send-or-delete-comment)
      - [View Own or Liked Posts](#view-own-or-liked-posts)
      - [Edit Profile](#edit-profile)
      - [Chat with Nearby Users](#chat-with-nearby-users)
  - [Team Members](#team-members)
  - [Technologies Applied](#technologies-applied)
  - [Development Setup](#development-setup)


## Introducion
Developed an iOS mobile application named What2Eat, aimed at resolving users' meal choice dilemmas and providing a platform for user-generated content, primarily through user posts. What2Eat seeks to simplify users' dining choices, encouraging the sharing of culinary experiences and social interaction.

User Posts: Users can share their food adventures, cooking ideas, and dining questions in the form of posts, creating their own food diaries.

Social Interaction: Users can like and comment on other users' posts and view posts they have liked.

Diverse Display: Users can browse geolocation-based posts in a map format.

Random Dining Selection: Users can search for posts with random food tags by shaking their device.

Social Interaction: Users can chat with other active users, with active users sorted by geographical proximity.

## [Demo Video]()


## User Guide and Key Features

### Guest Mode

#### Welcome
<p align="center">
<img src="readme_images/welcome.PNG" alt="Welcome View" width="200" height="400" align="center">
</p>

#### Read Posts as A Guest If YES
<p align="center">
<img src="readme_images/gmPosts.PNG" alt="Posts View" width="200" height="400" align="center">
  <img src="readme_images/gmMapPosts.PNG" alt="Map Posts View" width="200" height="400" align="center">
  <img src="readme_images/singlePost.jpeg" alt="SinglePost View" width="200" height="400" align="center">
</p>

#### Shake A Kind of Cuisine If NO
<p align="center">
  <img src="readme_images/shake.PNG" alt="Shake View" width="200" height="400" align="center">
  <img src="readme_images/shakePosts.PNG" alt="Shake View" width="200" height="400" align="center">
</p>


#### Log In or Sign Up 

<p align="center">
  <img src="readme_images/guestProfile.PNG" alt="Profile View" width="200" height="400" align="center">
  
  <img src="readme_images/signin.PNG" alt="Signin View" width="200" height="400" align="center">
  
  <img src="readme_images/signup.PNG" alt="Signup View" width="200" height="400" align="center">
  
</p>



### User Mode

#### Like Post or Comment
<p align="center">
  <img src="readme_images/userMode/likeAPost.PNG" alt="Like a Post" width="200" height="400" align="center">
  <img src="readme_images/userMode/likeAComment.PNG" alt="Like a Comment" width="200" height="400" align="center">
</p>

#### Send or Delete Post
<p align="center">
  <img src="readme_images/userMode/sendAPost.PNG" alt="Send a Post" width="200" height="400" align="center">
  <img src="readme_images/userMode/deleteAPost.PNG" alt="Delete a Post" width="200" height="400" align="center">
</p>

#### Send or Delete Comment
<p align="center">
  <img src="readme_images/userMode/sendAComment.PNG" alt="Send A Comment" width="200" height="400" align="center">
  <img src="readme_images/userMode/deleteAComment.PNG" alt="Delete A Comment" width="200" height="400" align="center">
</p>

#### View Own or Liked Posts
<p align="center">
  <img src="readme_images/userMode/ownPosts.PNG" alt="Own Posts" width="200" height="400" align="center">
  <img src="readme_images/userMode/likedPosts.PNG" alt="Liked Posts" width="200" height="400" align="center">
</p>

#### Edit Profile
<p align="center">
  <img src="readme_images/userMode/editProfile.PNG" alt="Edit Profile" width="200" height="400" align="center">
</p>

#### Chat with Nearby Users
<p align="center">
  <img src="readme_images/userMode/chat.PNG" alt="Chat" width="200" height="400" align="center">
  <img src="readme_images/userMode/findActive.PNG" alt="Find Active users" width="200" height="400" align="center">
  <img src="readme_images/userMode/sendMessage.PNG" alt="Send Message" width="200" height="400" align="center">
</p>




## Team Members

- [Bowen Fan](https://github.com/bowenfan-unimelb)
- [Junran Lin](https://github.com/junranLin)
- [Shuyu Chen](https://github.com/shuyu0619)
- [Tianqi Wang](https://github.com/terrance2630)
- [Yicong Wan](https://github.com/frankwan41)


## Technologies Applied

| Description     | Tool               |
| --------------- | ------------------ |
| Environment     | Xcode              |
| UI Design       | SwiftUI            |
| Development     | Swift              |
| Deployment      | Application Loader |
| Verison Control | Github             |
| Authentication  | Firebase           |
| Backend Database and Storage | Firebase |

## Development Setup

1. Clone the repo into Your Macbook
2. Open the folder COMP90018_APP in Xcode
3. Change the team(your personal team) and bundle ID (arbitrary one for testing) in General Setting
4. Build the Application on iPhone (In the developer mode and trust the application)
