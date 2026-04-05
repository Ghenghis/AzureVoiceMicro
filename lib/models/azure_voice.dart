class AzureVoice {
  final String id;
  final String displayName;
  final String locale;
  final String gender;
  final String style;

  const AzureVoice({
    required this.id,
    required this.displayName,
    required this.locale,
    required this.gender,
    this.style = 'neural',
  });
}

const List<AzureVoice> azureEnglishVoices = [
  AzureVoice(id: 'en-US-AriaNeural',       displayName: 'Aria',        locale: 'en-US', gender: 'Female'),
  AzureVoice(id: 'en-US-JennyNeural',      displayName: 'Jenny',       locale: 'en-US', gender: 'Female'),
  AzureVoice(id: 'en-US-GuyNeural',        displayName: 'Guy',         locale: 'en-US', gender: 'Male'),
  AzureVoice(id: 'en-US-EricNeural',       displayName: 'Eric',        locale: 'en-US', gender: 'Male'),
  AzureVoice(id: 'en-US-MichelleNeural',   displayName: 'Michelle',    locale: 'en-US', gender: 'Female'),
  AzureVoice(id: 'en-US-BrandonNeural',    displayName: 'Brandon',     locale: 'en-US', gender: 'Male'),
  AzureVoice(id: 'en-US-ChristopherNeural',displayName: 'Christopher', locale: 'en-US', gender: 'Male'),
  AzureVoice(id: 'en-US-ElizabethNeural',  displayName: 'Elizabeth',   locale: 'en-US', gender: 'Female'),
  AzureVoice(id: 'en-US-AnaNeural',        displayName: 'Ana',         locale: 'en-US', gender: 'Female'),
  AzureVoice(id: 'en-US-DavisNeural',      displayName: 'Davis',       locale: 'en-US', gender: 'Male'),
  AzureVoice(id: 'en-US-JasonNeural',      displayName: 'Jason',       locale: 'en-US', gender: 'Male'),
  AzureVoice(id: 'en-US-NancyNeural',      displayName: 'Nancy',       locale: 'en-US', gender: 'Female'),
  AzureVoice(id: 'en-US-TonyNeural',       displayName: 'Tony',        locale: 'en-US', gender: 'Male'),
  AzureVoice(id: 'en-GB-SoniaNeural',      displayName: 'Sonia',       locale: 'en-GB', gender: 'Female'),
  AzureVoice(id: 'en-GB-RyanNeural',       displayName: 'Ryan',        locale: 'en-GB', gender: 'Male'),
  AzureVoice(id: 'en-GB-LibbyNeural',      displayName: 'Libby',       locale: 'en-GB', gender: 'Female'),
  AzureVoice(id: 'en-AU-NatashaNeural',    displayName: 'Natasha',     locale: 'en-AU', gender: 'Female'),
  AzureVoice(id: 'en-AU-WilliamNeural',    displayName: 'William',     locale: 'en-AU', gender: 'Male'),
  AzureVoice(id: 'en-CA-ClaraNeural',      displayName: 'Clara',       locale: 'en-CA', gender: 'Female'),
  AzureVoice(id: 'en-CA-LiamNeural',       displayName: 'Liam',        locale: 'en-CA', gender: 'Male'),
  AzureVoice(id: 'en-IN-NeerjaNeural',     displayName: 'Neerja',      locale: 'en-IN', gender: 'Female'),
  AzureVoice(id: 'en-IN-PrabhatNeural',    displayName: 'Prabhat',     locale: 'en-IN', gender: 'Male'),
];
