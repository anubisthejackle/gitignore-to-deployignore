# Gitignore-to-Deployignore (G2D)

Circle CI uses your .gitignore files automatically when performing your deploys. The problems come when you need to add to your deployignore things that you do not want to add to your gitignore. In this circumstance, you need to manually create a .deployignore file, and consolidate all of your .gitignore files into a single file.

That's where G2D comes in.

By runing G2D in the root of your project, it will automatically locate, and consolidate, all of your .gitignore files into a single .deployignore. All of your customizations can be added to a special .deployignore.g2d file, which is automatically added to the compiled .deployignore file.

It's an easy to use tool, that automates some of the tedium of creating a .deployignore file.

## How to use
```
~/project/root # g2d
```