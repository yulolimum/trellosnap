# Trellosnap

```
NOTE: This is a work in progress. The extension does not yet work.
```

This is a Chrome Extension that will help with the task of website bug reporting via Trello. It will allow you to take a screenshot of a website page (entire browser window or partial selection) and annotate the screenshot (add arrows and boxes). After adding a card title and description, the screenshot will be uploaded to Trello to a board of your choosing, under a specific list, with an optional label. You will also be able to submit your browser information to help with further debugging.

### Development Setup

This extension uses Ruby and Node build tools. The following instructions assume that you have both Ruby 2.0+ and Node (with NPM) installed.

- Clone
- Run `gem install bundler`
- Run `npm install -g coffee-script`
- Run `npm install -g jade@1.8.1`
- Run `bundle`
- Run `foreman start`
- Tweak code within the `src` folders


### Timeline

###### 01-20-15

Hooked up the final event listeners. Implemented localStorage for previously used boards and lists. Added a login button. Added icons. Getting ready for verion 1 release.

###### 01-19-15

Styled the 'Add New Card' form.

![http://clrsight.co/yg/012015-tb025.jpg?+](http://clrsight.co/yg/012015-tb025.jpg?+)

###### 01-18-15

Finished the Trello API integrations. Got uploading working. Added basic forms to do test submits to Trello.

###### 01-16-15

Added annotations functionality. No text for now (since word wrapping is difficult with `<canvas>`) - only boxes and arrows. Started work on the Trello integration.

![http://clrsight.co/yg/011715-suzfz.jpg?+](http://clrsight.co/yg/011715-suzfz.jpg?+)

###### 01-15-15

Added functionality to the edit view. It now gets populated with the captured image. Started work on adding the annotations functionality.

![http://clrsight.co/yg/011615-p2xgu.jpg?+](http://clrsight.co/yg/011615-p2xgu.jpg?+)


###### 01-14-15

Finished the partial screenshot selection tool.

![http://clrsight.co/yg/011415-04huv.gif?+](http://clrsight.co/yg/011415-04huv.gif?+)

###### 01-13-15

Currently working on the partial page screenshot selection. There are no lightweight libraries out there that will do that; therefore, writing a custom solution.

###### 01-10-15

Hooked up event to capture visible page and send the image to an 'edit' screen. Styled the Browser Action:

![http://clrsight.co/yg/011015-x2ltt.jpg?+](http://clrsight.co/yg/011015-x2ltt.jpg?+)

###### 01-08-15

Set up project. File organization. Started throwing together needed files etc.
