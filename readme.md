# Trellosnap

```
This is a work in progress. The extension does not yet work.
```

This is a Chrome Extension that will help with the task of bug reporting. It allows you to take screenshots of a website page or custom selection - all of this can be annotated and edited before getting uploaded to Trello to a board of your choosing.

### Development Setup

This extension is built using both ruby and node technologies. The following instructions assume that you have both Rails and Node (with NPM) installed.

- Clone
- Run `gem install bundler`
- Run `npm install -g coffee-script`
- Run `npm install -g jade@1.8.1`
- Run `bundle`
- Run `foreman start`
- Tweak code within the `src` folders