# Mathphere-Web-Based-Learning-Platform
Web-based mathematics learning platform built with ASP.NET Web Forms, C#, and SQL Server, with student, teacher, and admin roles.

## Project Overview

This project was developed as a university project to demonstrate full-stack web application development using C#, SQL Server, JavaScript, HTML, and CSS. The system is designed to support mathematics learning in a more structured and engaging way by combining educational content, user management, assessments, and interactive support features in one platform.

## Main Features

### Student
- Browse modules and learning content
- Complete quizzes and timed assessments
- Review answers and past attempts
- Use the AI Tutor for learning support
- Access Math Playground tools such as graphing and geometry calculators
- Track progress with XP, streaks, and leaderboard rankings
- Join forum discussions and interact with posts

### Teacher
- Create and manage courses and modules
- Build assessments and question sets
- Configure content blocks such as text, quizzes, flashcards, and video lessons
- Enrol students into courses
- Monitor forum activity and provide feedback

### Admin
- Manage users and roles
- Configure system settings
- Moderate forum activity
- Manage support/help center content
- Monitor dashboard analytics and platform activity

## Additional Features

- AI Tutor chatbot integration
- Math Playground with:
  - Graph Explorer
  - Geometry Calculator
- Gamification system:
  - XP
  - streak tracking
  - leaderboard
- Interactive assessment workflow:
  - timed attempts
  - grading
  - result display
  - answer review

## Tech Stack

- ASP.NET Web Forms
- C#
- SQL Server
- JavaScript
- HTML
- CSS
- Tailwind utility styling in selected pages

## Project Structure

Key files and areas include:

- `Student.Master` / `Student.Master.cs`
- `teacher.Master` / `teacher.Master.cs`
- `admin.Master` / `admin.Master.cs`
- `StudentAssessment.aspx` / `StudentAssessment.aspx.cs`
- `GraphTool.aspx`
- `GeometryCalc.aspx`
- `Forum.aspx` / `Forum.aspx.cs`
- `moduleBuilder.aspx` / `moduleBuilder.aspx.cs`
- `courseListDashboard.aspx` / `courseListDashboard.aspx.cs`
