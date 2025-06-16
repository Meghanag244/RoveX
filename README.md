# RoveX - Social Biking & Travel Adventure App 🚲✈️

## Project Overview 🌟

RoveX (Ride, Travel, Experience, Adventure) is a community-driven platform designed to connect biking enthusiasts and travel adventurers. Our mission is to make biking and travel more accessible, social, and organized by bringing together people who share a passion for exploration and adventure.


<img width="250" alt="Screenshot 2025-06-16 at 1 34 58 PM" src="https://github.com/user-attachments/assets/9854f93c-7856-49ae-a08d-7ce782b71f67" />
<img width="250" alt="Screenshot 2025-06-16 at 1 39 06 PM" src="https://github.com/user-attachments/assets/7e6eae7e-fed8-416f-9a60-903833b3ba45" />
<img width="250" alt="Screenshot 2025-06-16 at 1 35 08 PM" src="https://github.com/user-attachments/assets/7ec5a82a-55f6-4654-931e-38a8f30d3005" />


### Vision 🎯
To create a vibrant community where bikers and travelers can easily find companions, share experiences, and explore the world together safely and efficiently.

### Core Values 💫
- **Community First**: Building a supportive and inclusive biking/travel community
- **Safety**: Ensuring secure and well-organized group activities
- **Accessibility**: Making biking and travel accessible to everyone
- **Adventure**: Encouraging exploration and new experiences
- **Sustainability**: Promoting responsible travel practices
<img width="200" alt="Screenshot 2025-06-16 at 1 40 56 PM" src="https://github.com/user-attachments/assets/78916f24-f91d-4835-befd-edee2290a9ca" />
<img width="250" alt="Screenshot 2025-06-16 at 1 41 24 PM" src="https://github.com/user-attachments/assets/9dce55a8-f942-4248-b275-3faabd6582ba" />
<img width="250" alt="Screenshot 2025-06-16 at 9 14 26 PM" src="https://github.com/user-attachments/assets/477b418d-02c0-4948-9fb5-27d4cb288188" />

## Detailed Features 🌈

### 1. User Experience 👤
- **Personalized Profiles**
  - Custom emoji avatars for visual identity
  - Travel history and achievements
  - Skill level indicators (biking expertise)
  - Personal adventure statistics

- **Smart Notifications**
  - Real-time updates for ride/trip changes
  - Weather alerts for planned activities
  - Safety notifications
  - Community announcements

### 2. Adventure Management 🗺️
- **Create Rides/Trips**
  - Detailed route information (difficulty, duration, distance)
  - Route planning with Google Maps integration
  - Weather forecasts integration
  - Capacity management
  - Required equipment lists
  - Safety guidelines

- **Join Adventures**
  - Browse available rides/trips with filters
  - View detailed route information
  - Check participant list
  - View leader's profile and experience
  - One-click join functionality

### 3. Group Features 👥
- **Real-time Communication**
  - In-ride/trip group chat
  - Photo sharing
  - Location sharing
  - Emergency alerts
  - Check-in system

- **Member Management**
  - Team leader controls
  - Participant verification
  - Skill level matching
  - Group size optimization
  - Waitlist management

### 4. Safety Features 🛡️
- **Location Tracking**
  - Real-time group location sharing
  - Emergency location broadcasting
  - Route deviation alerts
  - Checkpoint system

- **Safety Tools**
  - Weather alerts
  - Emergency contact system
  - First aid information
  - Road/trail condition updates

## For Users 👥

### New Bikers/Travelers 🆕
- Start with beginner-friendly rides
- Learn from experienced members
- Build your adventure profile
- Get safety tips and guidance

### Experienced Members 🏃
- Lead group rides/trips
- Share your expertise
- Create custom routes
- Mentor new members

### Adventure Leaders 👑
- Manage group activities
- Set route parameters
- Monitor participant safety
- Coordinate group logistics
<img width="250" alt="Screenshot 2025-06-16 at 9 14 39 PM" src="https://github.com/user-attachments/assets/fd9e92c5-f804-4b4d-bb3c-7321df7e4c66" />
<img width="250" alt="Screenshot 2025-06-16 at 9 14 49 PM" src="https://github.com/user-attachments/assets/af4344dd-8654-4997-a1d8-4016077c296f" />

## Technical Implementation 💻

### Architecture
- **Frontend**: Flutter for cross-platform compatibility
- **Backend**: Firebase for real-time data and scalability
- **State Management**: BLoC pattern for maintainable code
- **Location Services**: Google Maps and Geolocation APIs

### Security Measures
- End-to-end encryption for messages
- Secure user authentication
- Data privacy compliance
- Regular security audits

## Getting Started 🚀

1. **Clone the repository**
   ```bash
   git clone https://github.com/Meghanag244/RoveX.git
   cd roveeee
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a new Firebase project
   - Add Android/iOS apps in Firebase console
   - Download and add the configuration files:
     - Android: `google-services.json` to `android/app/`
     - iOS: `GoogleService-Info.plist` to `ios/Runner/`

4. **Environment Setup**
   - Create a `.env` file in the root directory
   - Add your Google Maps API key:
     ```
     GOOGLE_MAPS_API_KEY=your_api_key_here
     ```

5. **Run the app**
   ```bash
   flutter run
   ```

## Project Structure 📁

```
lib/
├── blocs/          # State management
├── models/         # Data models
├── screens/        # UI screens
├── services/       # Business logic
├── utils/          # Helper functions
└── widgets/        # Reusable widgets
```

## Contributing to the Project 🤝

### For Developers
1. **Code Standards**
   - Follow Flutter best practices
   - Write clean, documented code
   - Include unit tests
   - Follow the existing architecture

2. **Feature Development**
   - Create detailed feature proposals
   - Follow the branching strategy
   - Write comprehensive documentation
   - Include UI/UX considerations

### For Community Members
1. **Feedback**
   - Report bugs and issues
   - Suggest new features
   - Share user experience
   - Participate in testing

2. **Documentation**
   - Share travel experiences
   - Write route reviews
   - Contribute to safety guidelines
   - Create tutorial content

## Future Roadmap 🗺️

### Planned Features
1. **Advanced Features**
   - Offline mode
   - AR route navigation
   - Points of interest identification
   - Route condition reporting

2. **Community Features**
   - Adventure challenges
   - Achievement system
   - Community events
   - Expert verification

3. **Safety Enhancements**
   - AI-powered risk assessment
   - Advanced weather integration
   - Emergency response system
   - Health monitoring

## Support and Resources 📚

### Documentation
- [User Guide](link-to-user-guide)
- [API Documentation](link-to-api-docs)
- [Safety Guidelines](link-to-safety-guidelines)
- [Community Guidelines](link-to-community-guidelines)

### Community
- [Discord Server](link-to-discord)
- [Facebook Group](link-to-facebook)
- [Instagram](link-to-instagram)
- [Twitter](link-to-twitter)

## Security 🔒

- Firebase configuration files are not included in the repository
- API keys and sensitive information are stored in `.env` file
- Add `.env` to your `.gitignore`

## License 📝

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments 🙏

- Flutter team for the amazing framework
- Firebase for backend services
- All contributors and supporters

## Contact 📧

meghanag2244@gmail.com

