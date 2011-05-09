import promidi.*;

String lockSaveFile = "lock.txt";

boolean isRecordingLock = false;
boolean isRecordingKey = false;

ArrayList lock = new ArrayList();
ArrayList musicKey = new ArrayList();

int start;

int lastTime = 0;

boolean isLocked = false;
boolean isUnlocked = false;

PImage unlockedImage; // = loadImage("cylon.jpg");
PImage lockedImage; // = loadImage("notacylon2.jpg");

boolean lengthsMatch(int len1, int len2){
  return true;
//  return len1 * 0.8 - 100 <= len2 && len1 * 1.2 + 100 >= len2;
}

int time(){
  int ans = millis();
  if(ans < lastTime){
    return lastTime;
  }else{
    lastTime = ans;
    return lastTime;
  }
}

void draw(){
  int x = 350/2;
  int y = 275/2;
  noStroke();
  fill(0x55, 0x55, 0x55);
  rectMode(CORNER);
  rect(0,0,350,275);  
  rectMode(CENTER);
  imageMode(CENTER);
  textAlign(CENTER);
  textSize(20);
  fill(0,0,0);
  if(isUnlocked){
    image(unlockedImage,x,y);
  }else if(isLocked){
    image(lockedImage,x,y);
  }else if(isRecordingKey){
    text("Recording key.  Press space to finish.", x, y);
  }else if(isRecordingLock){
    text("Recording lock.  Press 'R' to finish.", x, y);
  }else{
    text("Press space to begin the key.", x, y);
  }
}

void setup(){
  MidiIO midiIO = MidiIO.getInstance();
  midiIO.printDevices();
  midiIO.openInput(0, 0);
  midiIO.plug(this, "noteOn", 0, 0);
  midiIO.plug(this, "noteOff", 0, 0);
  size(350, 275);
  unlockedImage = loadImage("cylon.jpg");
  lockedImage = loadImage("notacylon2.jpg");
  
  rectMode(CENTER);
  loadLock();
}
void noteOn(Note note){
  println("On.");
  start = time();
}

void noteOff(Note note){
  println("Off.");
  if(isRecordingKey){
    musicKey.add(note);
  }else if(isRecordingLock){
    lock.add(note);
  }
}

void mousePressed(){
  println("Mouse pressed.");
}

void reset(){
  isRecordingKey = false;
  isRecordingLock = false;
  isLocked = false;
  isUnlocked = false;
}

void saveLock(){
  int[] pitches = new int[lock.size()];
  for(int i=0;i<lock.size();i++){
    pitches[i] = ((Note) lock.get(i)).getPitch();
  }
  saveStrings(lockSaveFile, nfc(pitches));
}

void loadLock(){
  int[] pitches = int(loadStrings(lockSaveFile));
  lock.clear();
  for(int i=0;i<pitches.length;i++){
    lock.add(new Note(pitches[i], 1, 1));
  }
}

void keyPressed(){
  println("Key pressed.");
  switch(key){
    case '[':
      saveLock();
      break;
    case ']':
      loadLock();
      break;
    case ' ':
      if(isRecordingKey){
        // we're done recording the key, check it
        println("Key recorded.");
        reset();
        glue(musicKey);
        checkKey();
      }else{
        println("Recording key.");
        reset();
        isRecordingKey = true;
        musicKey.clear();
      }
      break;
    case 'r':
      if(isRecordingLock){
        println("Lock recorded.");
        reset();
        println(lock);
        glue(lock);
        println(lock);
      }else{
        println("Recording lock.");
        reset();
        isRecordingLock = true;
        lock.clear();
      }
  }
}

void checkKey(){
  println(lock);
  println(musicKey);
  if(keyMatches(lock, musicKey)){
    unlocked();
  }else{
    locked();
  }
}

void unlocked(){
  reset();
  isUnlocked = true;
  redraw();
  println("Unlocked.");
}

void locked(){
  reset();
  isLocked = true;
  redraw();
  println("Locked.");
}

boolean keyMatches(ArrayList lock, ArrayList musicKey){
  println(lock.size() + " ? " + musicKey.size());
  boolean good = lock.size() == musicKey.size();
  for(int i=0;i<lock.size() && good;i++){
    println(i);
    Note noteA = (Note) lock.get(i);
    Note noteB = (Note) musicKey.get(i);
    good = good && noteA.getPitch() == noteB.getPitch();
  }
  return good;
}

void glue(ArrayList music){
  for(int i=0;i + 1<music.size(); i++){
    Note a = (Note) music.get(i);
    Note b = (Note) music.get(i+1);
    if(a.getPitch() == b.getPitch()){
      music.remove(i+1);
      i--;
    }
  }
}
