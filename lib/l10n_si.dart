/// Sinhala text, keyed by the English text used in the code.
/// Anything missing here is shown in English.
const sinhala = <String, String>{
  // ---- statuses
  'Pending': 'පොරොත්තුවෙන්',
  'Confirmed': 'තහවුරුයි',
  'Rejected': 'ප්‍රතික්ෂේපයි',
  'Cancelled': 'අවලංගුයි',
  'Completed': 'අවසන්',
  'Request sent. Waiting for the doctor to reply.':
      'ඉල්ලීම යවා ඇත. වෛද්‍යවරයාගේ පිළිතුර ලැබෙන තුරු රැඳී සිටින්න.',
  'The doctor accepted the request.': 'වෛද්‍යවරයා ඉල්ලීම පිළිගත්තා.',
  'The doctor could not accept the request. The time is free again.':
      'වෛද්‍යවරයාට ඉල්ලීම පිළිගත නොහැකි විය. එම වේලාව නැවත විවෘතයි.',
  'The patient cancelled. The time is free again.':
      'රෝගියා අවලංගු කළා. එම වේලාව නැවත විවෘතයි.',
  'The visit is finished.': 'වෛද්‍ය හමුව අවසන්.',
  'Available': 'ලබා ගත හැක',
  'Reserved': 'වෙන් කර ඇත',
  'Booked': 'තහවුරු කර ඇත',
  'Unavailable': 'ලබා ගත නොහැක',
  'Selected': 'තෝරාගත්',

  // ---- dates
  'Today': 'අද',
  'Just now': 'මේ දැන්',
  '{0} min ago': 'මිනිත්තු {0}කට පෙර',
  '{0} h ago': 'පැය {0}කට පෙර',
  '{0} d ago': 'දින {0}කට පෙර',

  // ---- notifications
  'Appointment request sent': 'හමුව සඳහා ඉල්ලීම යැවුවා',
  'Your request to {0} for {1} is waiting for a reply.':
      '{1} සඳහා {0} වෙත යැවූ ඔබගේ ඉල්ලීමට පිළිතුර ලැබෙන තුරු රැඳී ඇත.',
  'Appointment confirmed': 'හමුව තහවුරුයි',
  '{0} accepted your request for {1}.': '{0} {1} සඳහා ඔබගේ ඉල්ලීම පිළිගත්තා.',
  'Appointment rejected': 'ඉල්ලීම ප්‍රතික්ෂේප විය',
  '{0} could not accept your request for {1}.':
      '{0} හට {1} සඳහා ඔබගේ ඉල්ලීම පිළිගත නොහැකි විය.',
  'Appointment cancelled': 'හමුව අවලංගු විය',
  'Your appointment with {0} on {1} was cancelled.':
      '{1} දින {0} සමඟ තිබූ ඔබගේ හමුව අවලංගු විය.',
  'Appointment completed': 'හමුව අවසන්',
  'Your visit to {0} on {1} is finished.': '{1} දින {0} හමුවීම අවසන් විය.',

  // ---- errors and validation
  'Choose a time in the future.': 'ඉදිරි වේලාවක් තෝරන්න.',
  'A slot already exists at this time.': 'මෙම වේලාවට දැනටමත් වේලාවක් ඇත.',
  'This overlaps with the {0} slot.': 'මෙය {0} වේලාව සමඟ ගැටේ.',
  'An account with this email already exists.':
      'මෙම ඊමේල් ලිපිනයෙන් ගිණුමක් දැනටමත් ඇත.',
  'Wrong email or password. Please try again.':
      'ඊමේල් හෝ මුරපදය වැරදියි. නැවත උත්සාහ කරන්න.',
  'This doctor account is switched off. Please contact the admin.':
      'මෙම වෛද්‍ය ගිණුම අක්‍රිය කර ඇත. පරිපාලක අමතන්න.',
  'Enter your email': 'ඔබගේ ඊමේල් ලිපිනය ඇතුළත් කරන්න',
  'Enter a valid email address': 'නිවැරදි ඊමේල් ලිපිනයක් ඇතුළත් කරන්න',
  'Enter your password': 'ඔබගේ මුරපදය ඇතුළත් කරන්න',
  'Enter your full name': 'ඔබගේ සම්පූර්ණ නම ඇතුළත් කරන්න',
  'Use at least 6 characters': 'අවම වශයෙන් අකුරු 6ක් භාවිත කරන්න',
  'Passwords do not match': 'මුරපද දෙක ගැළපෙන්නේ නැත',
  'Could not load this page': 'මෙම පිටුව පූරණය කළ නොහැකි විය',
  'Check your internet connection and try again.':
      'ඔබගේ අන්තර්ජාල සම්බන්ධතාව පරීක්ෂා කර නැවත උත්සාහ කරන්න.',
  'Try Again': 'නැවත උත්සාහ කරන්න',

  // ---- common
  'Cancel': 'ආපසු',
  'Go Back': 'ආපසු',
  'Email': 'ඊමේල්',
  'Password': 'මුරපදය',
  'Patient': 'රෝගියා',
  'Doctor': 'වෛද්‍යවරයා',
  'Admin': 'පරිපාලක',
  'Date': 'දිනය',
  'Time': 'වේලාව',
  'Clinic': 'සායනය',
  'Status': 'තත්ත්වය',
  'Profile': 'ගිණුම',
  'Home': 'මුල් පිටුව',
  'Appointments': 'හමුවීම්',
  'Notifications': 'දැනුම්දීම්',

  // ---- launch, login, register, forgot password
  'Your doctor, one tap away': 'ඔබේ වෛද්‍යවරයා, එක ස්පර්ශයකින්',
  'Log in to find a doctor and book a visit':
      'වෛද්‍යවරයෙකු සොයා හමුවක් වෙන් කිරීමට ඇතුළු වන්න',
  'Show password': 'මුරපදය පෙන්වන්න',
  'Hide password': 'මුරපදය සඟවන්න',
  'Forgot Password?': 'මුරපදය අමතකද?',
  'Log In': 'ඇතුළු වන්න',
  'Create Patient Account': 'රෝගී ගිණුමක් සාදන්න',
  'Demo accounts – tap to fill': 'ආදර්ශ ගිණුම් – පිරවීමට ස්පර්ශ කරන්න',
  'Account created. Welcome to MyDoctor!':
      'ගිණුම සාදන ලදී. MyDoctor වෙත සාදරයෙන් පිළිගනිමු!',
  'Create an account to find doctors and book visits.':
      'වෛද්‍යවරුන් සොයා හමුවීම් වෙන් කිරීමට ගිණුමක් සාදන්න.',
  'Full name': 'සම්පූර්ණ නම',
  'At least 6 characters': 'අවම අකුරු 6ක්',
  'Confirm password': 'මුරපදය නැවත ඇතුළත් කරන්න',
  'Create Account': 'ගිණුම සාදන්න',
  'Already have an account? Log In': 'දැනටමත් ගිණුමක් තිබේද? ඇතුළු වන්න',
  'Forgot Password': 'මුරපදය අමතකද',
  'Enter your email. We will send you a link to make a new password.':
      'ඔබගේ ඊමේල් ලිපිනය ඇතුළත් කරන්න. නව මුරපදයක් සෑදීමට සබැඳියක් අපි '
      'ඔබට එවන්නෙමු.',
  'Send Reset Link': 'සබැඳිය එවන්න',
  'Check your email': 'ඔබගේ ඊමේල් බලන්න',
  'If there is an account for {0}, we have sent a link to make a new '
          'password.':
      '{0} සඳහා ගිණුමක් තිබේ නම්, නව මුරපදයක් සෑදීමට සබැඳියක් අපි යවා ඇත.',
  'Back to Log In': 'ඇතුළු වීමට ආපසු',
  'Use a different email': 'වෙනත් ඊමේල් ලිපිනයක් භාවිත කරන්න',

  // ---- account and settings
  'Sign out?': 'ඉවත් වන්නද?',
  'You will need to log in again to use MyDoctor.':
      'MyDoctor භාවිත කිරීමට ඔබට නැවත ඇතුළු වීමට සිදු වේ.',
  'Sign Out': 'ඉවත් වන්න',
  'Language': 'භාෂාව',
  'App language': 'යෙදුමේ භාෂාව',
  'Booking updates': 'වෙන් කිරීම් පිළිබඳ දැනුම්දීම්',
  'When a request is accepted, rejected or cancelled':
      'ඉල්ලීමක් පිළිගත්, ප්‍රතික්ෂේප කළ හෝ අවලංගු කළ විට',
  'Appointment reminders': 'හමුවීම් මතක් කිරීම්',
  'The day before an appointment': 'හමුවට පෙර දින',
  'Prototype options': 'පරීක්ෂණ විකල්ප',
  'Fail the next page load': 'ඊළඟ පිටුව පූරණය අසාර්ථක කරන්න',
  'Shows the "Try Again" screen once':
      '"නැවත උත්සාහ කරන්න" තිරය එක් වරක් පෙන්වයි',
  'Take my time slot on next request':
      'ඊළඟ ඉල්ලීමේදී මගේ වේලාව වෙනත් අයෙකුට දෙන්න',
  'Shows the "no longer available" message once':
      '"තවදුරටත් ලබා ගත නොහැක" පණිවිඩය එක් වරක් පෙන්වයි',
  'Account & Settings': 'ගිණුම සහ සැකසුම්',

  // ---- appointment details
  'Request Details': 'ඉල්ලීමේ විස්තර',
  'Appointment Details': 'හමුවේ විස්තර',
  'What has happened so far': 'මෙතෙක් සිදු වූ දේ',
  'Cancel appointment?': 'හමුව අවලංගු කරන්නද?',
  'Your appointment on {0} will be cancelled. The time will be given to '
          'other patients.':
      '{0} දින ඔබගේ හමුව අවලංගු වේ. එම වේලාව වෙනත් රෝගීන්ට ලබා දේ.',
  'Cancel Appointment': 'හමුව අවලංගු කරන්න',
  'Appointment cancelled. The time is free again.':
      'හමුව අවලංගු කළා. එම වේලාව නැවත විවෘතයි.',
  'Cancelling…': 'අවලංගු කරමින්…',
  'Reject request?': 'ඉල්ලීම ප්‍රතික්ෂේප කරන්නද?',
  '{0} will be told that the request for {1} was rejected. The time '
          'becomes free again.':
      '{1} සඳහා වූ ඉල්ලීම ප්‍රතික්ෂේප වූ බව {0} හට දන්වනු ලැබේ. එම වේලාව '
      'නැවත විවෘත වේ.',
  'Reject': 'ප්‍රතික්ෂේප කරන්න',
  'Request rejected. The time is free again.':
      'ඉල්ලීම ප්‍රතික්ෂේප කළා. එම වේලාව නැවත විවෘතයි.',
  'Accept request?': 'ඉල්ලීම පිළිගන්නද?',
  'This confirms the appointment with {0} on {1}.':
      'මෙයින් {1} දින {0} සමඟ හමුව තහවුරු වේ.',
  'Accept': 'පිළිගන්න',
  'Appointment confirmed.': 'හමුව තහවුරු කළා.',
  'Mark as Completed': 'අවසන් ලෙස සලකුණු කරන්න',
  'Mark as completed?': 'අවසන් ලෙස සලකුණු කරන්නද?',
  'Confirm that the visit with {0} is finished.':
      '{0} සමඟ හමුව අවසන් වූ බව තහවුරු කරන්න.',
  'Mark Completed': 'අවසන් කරන්න',
  'Appointment marked as completed.': 'හමුව අවසන් ලෙස සලකුණු කළා.',

  // ---- patient: find doctors
  'Hello, {0} 👋': 'ආයුබෝවන්, {0} 👋',
  'Find a doctor': 'වෛද්‍යවරයෙකු සොයන්න',
  'Search doctor or sickness (e.g. fever)':
      'වෛද්‍යවරයා හෝ රෝගය සොයන්න (උදා: උණ)',
  'Clear search': 'සෙවුම මකන්න',
  'Clear Search': 'සෙවුම මකන්න',
  'What is your health problem?': 'ඔබගේ සෞඛ්‍ය ගැටලුව කුමක්ද?',
  'Doctors': 'වෛද්‍යවරු',
  '{0} found': '{0}ක් හමු විය',
  'No doctors found': 'වෛද්‍යවරුන් හමු නොවීය',
  'Try another word, or clear the search to see all doctors.':
      'වෙනත් වචනයක් උත්සාහ කරන්න, නැතහොත් සියලු වෛද්‍යවරුන් බැලීමට සෙවුම '
      'මකන්න.',
  'You need a {0}': 'ඔබ හමුවිය යුත්තේ: {0}',
  'Helps with: {0}': 'ප්‍රතිකාර: {0}',
  'Helps with': 'ප්‍රතිකාර කරන රෝග',
  'Show all doctors': 'සියලු වෛද්‍යවරුන් පෙන්වන්න',
  'View Profile': 'විස්තර බලන්න',

  // ---- patient: doctor profile and booking
  'Doctor Profile': 'වෛද්‍ය විස්තර',
  'Clinic location': 'සායනය පිහිටි ස්ථානය',
  'About the doctor': 'වෛද්‍යවරයා ගැන',
  'View Availability': 'ලබා ගත හැකි වේලාවන් බලන්න',
  'Select Appointment': 'දිනය සහ වේලාව තෝරන්න',
  'Selected date': 'තෝරාගත් දිනය',
  'Choose a time': 'වේලාවක් තෝරන්න',
  'Continue with {0}': '{0} සමඟ ඉදිරියට',
  'No times on this day': 'මෙම දිනයේ වේලාවන් නැත',
  'The doctor has no appointment times on {0}. Please choose another '
          'date.':
      '{0} දින වෛද්‍යවරයාට හමුවීම් වේලාවන් නැත. වෙනත් දිනයක් තෝරන්න.',
  'All times on this day are taken. Please choose another date.':
      'මෙම දිනයේ සියලු වේලාවන් වෙන් වී ඇත. වෙනත් දිනයක් තෝරන්න.',
  'Morning': 'උදේ',
  'Afternoon': 'දහවල්',
  'Review Appointment': 'හමුව පරීක්ෂා කරන්න',
  'This time is no longer available. Please choose another slot':
      'මෙම වේලාව තවදුරටත් ලබා ගත නොහැක. වෙනත් වේලාවක් තෝරන්න',
  'Choose Another Slot': 'වෙනත් වේලාවක් තෝරන්න',
  'Kind of doctor': 'වෛද්‍ය වර්ගය',
  'Your request stays Pending until the doctor replies. The time is kept '
          'for you until then.':
      'වෛද්‍යවරයා පිළිතුරු දෙන තුරු ඔබගේ ඉල්ලීම පොරොත්තුවෙන් පවතී. එතෙක් '
      'එම වේලාව ඔබ වෙනුවෙන් තබා ගනී.',
  'Request Appointment': 'හමුව ඉල්ලන්න',
  'Change Time': 'වේලාව වෙනස් කරන්න',
  'Your doctor will review your request.':
      'ඔබගේ වෛද්‍යවරයා ඔබගේ ඉල්ලීම පරීක්ෂා කරනු ඇත.',
  'Date and time': 'දිනය සහ වේලාව',
  'View Appointment': 'හමුව බලන්න',
  'Back to Home': 'මුල් පිටුවට',

  // ---- patient: appointments and notifications
  'My Appointments': 'මගේ හමුවීම්',
  'Upcoming': 'ඉදිරියට ඇති',
  'History': 'පසුගිය',
  'No upcoming appointments': 'ඉදිරියට හමුවීම් නැත',
  'Go to Home and choose a doctor to book your first appointment.':
      'ඔබගේ පළමු හමුව වෙන් කිරීමට මුල් පිටුවට ගොස් වෛද්‍යවරයෙකු තෝරන්න.',
  'No past appointments': 'පසුගිය හමුවීම් නැත',
  'Completed, cancelled and rejected appointments will be shown here.':
      'අවසන් වූ, අවලංගු වූ සහ ප්‍රතික්ෂේප වූ හමුවීම් මෙහි පෙන්වයි.',
  'Mark all read': 'සියල්ල කියවූ ලෙස',
  'No notifications yet': 'තවම දැනුම්දීම් නැත',
  'News about your bookings will be shown here.':
      'ඔබගේ වෙන් කිරීම් පිළිබඳ තොරතුරු මෙහි පෙන්වයි.',
  'New': 'අලුත්',

  // ---- doctor
  'Dashboard': 'මුල් පිටුව',
  'Schedule': 'කාලසටහන',
  'Doctor details': 'වෛද්‍ය තොරතුරු',
  'About': 'විස්තරය',
  'Pending requests': 'පොරොත්තු ඉල්ලීම්',
  'Nothing to review right now': 'දැනට පරීක්ෂා කිරීමට කිසිවක් නැත',
  'Patients are waiting for your reply':
      'රෝගීන් ඔබගේ පිළිතුර බලාපොරොත්තුවෙන් සිටී',
  'Review Requests': 'ඉල්ලීම් බලන්න',
  'Manage Availability': 'වේලාවන් කළමනාකරණය',
  'Today\'s schedule': 'අද කාලසටහන',
  'No confirmed appointments today.': 'අද තහවුරු කළ හමුවීම් නැත.',
  'View Request': 'ඉල්ලීම බලන්න',
  'No pending requests': 'පොරොත්තු ඉල්ලීම් නැත',
  'New appointment requests from patients will be shown here.':
      'රෝගීන්ගෙන් ලැබෙන නව ඉල්ලීම් මෙහි පෙන්වයි.',
  'Appointment Requests': 'හමුවීම් ඉල්ලීම්',
  'Requests': 'ඉල්ලීම්',
  'Appointments you accept will be shown here as Confirmed.':
      'ඔබ පිළිගන්නා හමුවීම් තහවුරු ලෙස මෙහි පෙන්වයි.',
  'Add Slot': 'වේලාවක් එක් කරන්න',
  'Tap Add Slot to open appointment times for patients.':
      'රෝගීන් සඳහා වේලාවන් විවෘත කිරීමට "වේලාවක් එක් කරන්න" ඔබන්න.',
  'a patient': 'රෝගියෙකු',
  'Open for booking': 'වෙන් කිරීමට විවෘතයි',
  'Kept for {0} · waiting for your reply':
      '{0} සඳහා තබා ඇත · ඔබගේ පිළිතුර බලාපොරොත්තුවෙන්',
  'Confirmed with {0}': '{0} සමඟ තහවුරුයි',
  'Edit slot': 'වේලාව සංස්කරණය',
  'Locked': 'අගුළු දමා ඇත',
  'Slot updated.': 'වේලාව යාවත්කාලීන කළා.',
  'Slot added.': 'වේලාව එක් කළා.',
  'Remove slot?': 'වේලාව ඉවත් කරන්නද?',
  'Patients will no longer be able to book {0} on {1}.':
      'රෝගීන්ට {1} දින {0} වේලාව තවදුරටත් වෙන් කළ නොහැක.',
  'Remove': 'ඉවත් කරන්න',
  'Slot removed.': 'වේලාව ඉවත් කළා.',
  'Edit Availability': 'වේලාව සංස්කරණය',
  'This slot is {0}. You cannot change or remove it while a patient has '
          'it.':
      'මෙම වේලාව: {0}. රෝගියෙකු සතුව ඇති තාක් එය වෙනස් කිරීමට හෝ ඉවත් '
      'කිරීමට නොහැක.',
  'Start time': 'ආරම්භක වේලාව',
  'Each slot is {0} minutes: {1} – {2}.':
      'එක් වේලාවක් මිනිත්තු {0}කි: {1} – {2}.',
  'Save Slot': 'වේලාව සුරකින්න',
  'Remove Slot': 'වේලාව ඉවත් කරන්න',
};
