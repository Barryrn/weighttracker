Architecture & Structure
• Use Flutter with a strict MVVM architecture: Model, View, ViewModel.
• Keep business logic inside the
• Maintain strict separation of concerns.

Comments & Documentation
• Every method, class, and non-trivial logic must be commented.
• Comments should explain:
• The purpose of the code
• Input and output types
• Edge cases, side effects, or asynchronous behavior

UI & Design
• Use a modern, clean UI style:
• Rounded corners, shadows, smooth animations
• Responsive layouts using LayoutBuilder, MediaQuery, or other adaptive techniques
• Use ThemeData for all colors, spacing, and typography
• Support Dark Mode and Accessibility including semantic widgets and text scaling
• Use AppColors and AppTypography for consistent color and typography throughout the app

Clean Code & Best Practices
• Follow SOLID principles and DRY (Don’t Repeat Yourself)
• Use Provider or Riverpod for state management (recommended)
• Break down UI into reusable, stateless widgets
• Use clear, consistent, and descriptive names for all files, classes, and methods
• Enforce code quality using a linter
• Use try and catch blocks for all asynchronous or error-prone operations
• Always handle exceptions explicitly and log meaningful error messages
• Avoid silent failures, fallback gracefully when possible

Debugging & Logging
• Use structured logging tools such as the logger package
• Remove all debugging code and logs in production builds

Trae AI Behavior
• Always write comments, even for simple logic
• follow the MVVM pattern
• Use modern Flutter components and best practices
• Never hardcode strings, colors, or values, use constants, theme files, or localization
