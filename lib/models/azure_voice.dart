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

/// Static fallback list — used before/if Azure API fetch fails.
/// Dynamic fetch via AzureTtsService.fetchVoiceList() returns the full live catalogue.
const List<AzureVoice> azureEnglishVoices = [
  // ── en-US ──────────────────────────────────────────────────────────────
  AzureVoice(id: 'en-US-AriaNeural',         displayName: 'Aria (US)',         locale: 'en-US', gender: 'Female'),
  AzureVoice(id: 'en-US-JennyNeural',        displayName: 'Jenny (US)',        locale: 'en-US', gender: 'Female'),
  AzureVoice(id: 'en-US-GuyNeural',          displayName: 'Guy (US)',          locale: 'en-US', gender: 'Male'),
  AzureVoice(id: 'en-US-EricNeural',         displayName: 'Eric (US)',         locale: 'en-US', gender: 'Male'),
  AzureVoice(id: 'en-US-MichelleNeural',     displayName: 'Michelle (US)',     locale: 'en-US', gender: 'Female'),
  AzureVoice(id: 'en-US-BrandonNeural',      displayName: 'Brandon (US)',      locale: 'en-US', gender: 'Male'),
  AzureVoice(id: 'en-US-ChristopherNeural',  displayName: 'Christopher (US)',  locale: 'en-US', gender: 'Male'),
  AzureVoice(id: 'en-US-ElizabethNeural',    displayName: 'Elizabeth (US)',    locale: 'en-US', gender: 'Female'),
  AzureVoice(id: 'en-US-AnaNeural',          displayName: 'Ana (US)',          locale: 'en-US', gender: 'Female'),
  AzureVoice(id: 'en-US-DavisNeural',        displayName: 'Davis (US)',        locale: 'en-US', gender: 'Male'),
  AzureVoice(id: 'en-US-JasonNeural',        displayName: 'Jason (US)',        locale: 'en-US', gender: 'Male'),
  AzureVoice(id: 'en-US-NancyNeural',        displayName: 'Nancy (US)',        locale: 'en-US', gender: 'Female'),
  AzureVoice(id: 'en-US-TonyNeural',         displayName: 'Tony (US)',         locale: 'en-US', gender: 'Male'),
  AzureVoice(id: 'en-US-AmberNeural',        displayName: 'Amber (US)',        locale: 'en-US', gender: 'Female'),
  AzureVoice(id: 'en-US-AshleyNeural',       displayName: 'Ashley (US)',       locale: 'en-US', gender: 'Female'),
  AzureVoice(id: 'en-US-CoraNeural',         displayName: 'Cora (US)',         locale: 'en-US', gender: 'Female'),
  AzureVoice(id: 'en-US-ElizabethNeural',    displayName: 'Elizabeth (US)',    locale: 'en-US', gender: 'Female'),
  AzureVoice(id: 'en-US-EvelynNeural',       displayName: 'Evelyn (US)',       locale: 'en-US', gender: 'Female'),
  AzureVoice(id: 'en-US-JaneNeural',         displayName: 'Jane (US)',         locale: 'en-US', gender: 'Female'),
  AzureVoice(id: 'en-US-MonicaNeural',       displayName: 'Monica (US)',       locale: 'en-US', gender: 'Female'),
  AzureVoice(id: 'en-US-SaraNeural',         displayName: 'Sara (US)',         locale: 'en-US', gender: 'Female'),
  AzureVoice(id: 'en-US-DerekNeural',        displayName: 'Derek (US)',        locale: 'en-US', gender: 'Male'),
  AzureVoice(id: 'en-US-DustinNeural',       displayName: 'Dustin (US)',       locale: 'en-US', gender: 'Male'),
  AzureVoice(id: 'en-US-KaiNeural',          displayName: 'Kai (US)',          locale: 'en-US', gender: 'Male'),
  AzureVoice(id: 'en-US-LunaNeural',         displayName: 'Luna (US)',         locale: 'en-US', gender: 'Female'),
  AzureVoice(id: 'en-US-NovaNeural',         displayName: 'Nova (US)',         locale: 'en-US', gender: 'Female'),
  AzureVoice(id: 'en-US-SteffanNeural',      displayName: 'Steffan (US)',      locale: 'en-US', gender: 'Male'),
  AzureVoice(id: 'en-US-AIGenerate1Neural',  displayName: 'AI Gen 1 (US)',     locale: 'en-US', gender: 'Male'),
  AzureVoice(id: 'en-US-AIGenerate2Neural',  displayName: 'AI Gen 2 (US)',     locale: 'en-US', gender: 'Female'),
  // ── en-GB ──────────────────────────────────────────────────────────────
  AzureVoice(id: 'en-GB-SoniaNeural',        displayName: 'Sonia (GB)',        locale: 'en-GB', gender: 'Female'),
  AzureVoice(id: 'en-GB-RyanNeural',         displayName: 'Ryan (GB)',         locale: 'en-GB', gender: 'Male'),
  AzureVoice(id: 'en-GB-LibbyNeural',        displayName: 'Libby (GB)',        locale: 'en-GB', gender: 'Female'),
  AzureVoice(id: 'en-GB-AbbiNeural',         displayName: 'Abbi (GB)',         locale: 'en-GB', gender: 'Female'),
  AzureVoice(id: 'en-GB-AlfieNeural',        displayName: 'Alfie (GB)',        locale: 'en-GB', gender: 'Male'),
  AzureVoice(id: 'en-GB-BellaNeural',        displayName: 'Bella (GB)',        locale: 'en-GB', gender: 'Female'),
  AzureVoice(id: 'en-GB-ElliotNeural',       displayName: 'Elliot (GB)',       locale: 'en-GB', gender: 'Male'),
  AzureVoice(id: 'en-GB-EthanNeural',        displayName: 'Ethan (GB)',        locale: 'en-GB', gender: 'Male'),
  AzureVoice(id: 'en-GB-HollyNeural',        displayName: 'Holly (GB)',        locale: 'en-GB', gender: 'Female'),
  AzureVoice(id: 'en-GB-MaisieNeural',       displayName: 'Maisie (GB)',       locale: 'en-GB', gender: 'Female'),
  AzureVoice(id: 'en-GB-NoahNeural',         displayName: 'Noah (GB)',         locale: 'en-GB', gender: 'Male'),
  AzureVoice(id: 'en-GB-OliverNeural',       displayName: 'Oliver (GB)',       locale: 'en-GB', gender: 'Male'),
  AzureVoice(id: 'en-GB-OliviaNeural',       displayName: 'Olivia (GB)',       locale: 'en-GB', gender: 'Female'),
  AzureVoice(id: 'en-GB-ThomasNeural',       displayName: 'Thomas (GB)',       locale: 'en-GB', gender: 'Male'),
  // ── en-AU ──────────────────────────────────────────────────────────────
  AzureVoice(id: 'en-AU-NatashaNeural',      displayName: 'Natasha (AU)',      locale: 'en-AU', gender: 'Female'),
  AzureVoice(id: 'en-AU-WilliamNeural',      displayName: 'William (AU)',      locale: 'en-AU', gender: 'Male'),
  AzureVoice(id: 'en-AU-AnnetteNeural',      displayName: 'Annette (AU)',      locale: 'en-AU', gender: 'Female'),
  AzureVoice(id: 'en-AU-CarlyseNeural',      displayName: 'Carlyse (AU)',      locale: 'en-AU', gender: 'Female'),
  AzureVoice(id: 'en-AU-DarrenNeural',       displayName: 'Darren (AU)',       locale: 'en-AU', gender: 'Male'),
  AzureVoice(id: 'en-AU-DuncanNeural',       displayName: 'Duncan (AU)',       locale: 'en-AU', gender: 'Male'),
  AzureVoice(id: 'en-AU-ElsieNeural',        displayName: 'Elsie (AU)',        locale: 'en-AU', gender: 'Female'),
  AzureVoice(id: 'en-AU-FreyaNeural',        displayName: 'Freya (AU)',        locale: 'en-AU', gender: 'Female'),
  AzureVoice(id: 'en-AU-JoanneNeural',       displayName: 'Joanne (AU)',       locale: 'en-AU', gender: 'Female'),
  AzureVoice(id: 'en-AU-KenNeural',          displayName: 'Ken (AU)',          locale: 'en-AU', gender: 'Male'),
  AzureVoice(id: 'en-AU-KimNeural',          displayName: 'Kim (AU)',          locale: 'en-AU', gender: 'Female'),
  AzureVoice(id: 'en-AU-NeilNeural',         displayName: 'Neil (AU)',         locale: 'en-AU', gender: 'Male'),
  AzureVoice(id: 'en-AU-TimNeural',          displayName: 'Tim (AU)',          locale: 'en-AU', gender: 'Male'),
  AzureVoice(id: 'en-AU-TinaNeural',         displayName: 'Tina (AU)',         locale: 'en-AU', gender: 'Female'),
  // ── en-CA ──────────────────────────────────────────────────────────────
  AzureVoice(id: 'en-CA-ClaraNeural',        displayName: 'Clara (CA)',        locale: 'en-CA', gender: 'Female'),
  AzureVoice(id: 'en-CA-LiamNeural',         displayName: 'Liam (CA)',         locale: 'en-CA', gender: 'Male'),
  // ── en-IN ──────────────────────────────────────────────────────────────
  AzureVoice(id: 'en-IN-NeerjaNeural',       displayName: 'Neerja (IN)',       locale: 'en-IN', gender: 'Female'),
  AzureVoice(id: 'en-IN-PrabhatNeural',      displayName: 'Prabhat (IN)',      locale: 'en-IN', gender: 'Male'),
  AzureVoice(id: 'en-IN-AaravNeural',        displayName: 'Aarav (IN)',        locale: 'en-IN', gender: 'Male'),
  AzureVoice(id: 'en-IN-AnanyaNeural',       displayName: 'Ananya (IN)',       locale: 'en-IN', gender: 'Female'),
  AzureVoice(id: 'en-IN-KavyaNeural',        displayName: 'Kavya (IN)',        locale: 'en-IN', gender: 'Female'),
  AzureVoice(id: 'en-IN-KunalNeural',        displayName: 'Kunal (IN)',        locale: 'en-IN', gender: 'Male'),
  AzureVoice(id: 'en-IN-RehaanNeural',       displayName: 'Rehaan (IN)',       locale: 'en-IN', gender: 'Male'),
  // ── en-IE ──────────────────────────────────────────────────────────────
  AzureVoice(id: 'en-IE-ConnorNeural',       displayName: 'Connor (IE)',       locale: 'en-IE', gender: 'Male'),
  AzureVoice(id: 'en-IE-EmilyNeural',        displayName: 'Emily (IE)',        locale: 'en-IE', gender: 'Female'),
  // ── en-NZ ──────────────────────────────────────────────────────────────
  AzureVoice(id: 'en-NZ-MollyNeural',        displayName: 'Molly (NZ)',        locale: 'en-NZ', gender: 'Female'),
  AzureVoice(id: 'en-NZ-MitchellNeural',     displayName: 'Mitchell (NZ)',     locale: 'en-NZ', gender: 'Male'),
  // ── en-SG ──────────────────────────────────────────────────────────────
  AzureVoice(id: 'en-SG-LunaNeural',         displayName: 'Luna (SG)',         locale: 'en-SG', gender: 'Female'),
  AzureVoice(id: 'en-SG-WayneNeural',        displayName: 'Wayne (SG)',        locale: 'en-SG', gender: 'Male'),
  // ── en-ZA ──────────────────────────────────────────────────────────────
  AzureVoice(id: 'en-ZA-LeahNeural',         displayName: 'Leah (ZA)',         locale: 'en-ZA', gender: 'Female'),
  AzureVoice(id: 'en-ZA-LukeNeural',         displayName: 'Luke (ZA)',         locale: 'en-ZA', gender: 'Male'),
  // ── en-HK ──────────────────────────────────────────────────────────────
  AzureVoice(id: 'en-HK-SamNeural',          displayName: 'Sam (HK)',          locale: 'en-HK', gender: 'Male'),
  AzureVoice(id: 'en-HK-YanNeural',          displayName: 'Yan (HK)',          locale: 'en-HK', gender: 'Female'),
  // ── en-PH ──────────────────────────────────────────────────────────────
  AzureVoice(id: 'en-PH-JamesNeural',        displayName: 'James (PH)',        locale: 'en-PH', gender: 'Male'),
  AzureVoice(id: 'en-PH-RosaNeural',         displayName: 'Rosa (PH)',         locale: 'en-PH', gender: 'Female'),
  // ── en-KE ──────────────────────────────────────────────────────────────
  AzureVoice(id: 'en-KE-AsiliaNeural',       displayName: 'Asilia (KE)',       locale: 'en-KE', gender: 'Female'),
  AzureVoice(id: 'en-KE-ChilembaNeural',     displayName: 'Chilemba (KE)',     locale: 'en-KE', gender: 'Male'),
  // ── en-NG ──────────────────────────────────────────────────────────────
  AzureVoice(id: 'en-NG-AbeoNeural',         displayName: 'Abeo (NG)',         locale: 'en-NG', gender: 'Male'),
  AzureVoice(id: 'en-NG-EzinneNeural',       displayName: 'Ezinne (NG)',       locale: 'en-NG', gender: 'Female'),
  // ── en-TZ ──────────────────────────────────────────────────────────────
  AzureVoice(id: 'en-TZ-ElimuNeural',        displayName: 'Elimu (TZ)',        locale: 'en-TZ', gender: 'Male'),
  AzureVoice(id: 'en-TZ-ImaniNeural',        displayName: 'Imani (TZ)',        locale: 'en-TZ', gender: 'Female'),
];
