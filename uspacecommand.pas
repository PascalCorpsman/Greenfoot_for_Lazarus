(*
 * made by Corpsman, www.Corpsman.de
 *
 * Version : 0.01
 * History : 0.01 = Initial version ( TBigRock, TRock, TEnemy )
 *
 * Todo : New Weapons for the player..
 *)

Unit uspacecommand;

{$MODE objfpc}{$H+}

Interface

Uses
  SysUtils,
  math,
  ugreenfoot,
  uvectormath,
  OpenGLContext;

Const
  corners = 10;

Type

  { TCounter }

  TCounter = Class(TActor)
  private
    text: String;
    StringLength: integer;
    Procedure UpdateImage();
  public
    value: integer;
    Constructor Create(); override;
    Constructor Create(prefix: String);
    Destructor destroy(); override;
    Procedure Increment(Value_: integer);
  End;

  { TEnemy }

  TEnemy = Class(TActor)
  private
    goal: TActor;
    pos, speed: TVector2;
    worldwidth, worldheight: integer;
    GunLoadTimer: Integer;
  public
    Constructor create(); override;
    Procedure addedToWorld(Const World: TWorld); override;
    Procedure Act(); override;
  End;

  { TBigRock }

  TBigRock = Class(TActor)
  private
    speed, pos: TVector2;
    worldwidth, worldheight: integer;
  public
    Constructor create(); override;
    Procedure addedToWorld(Const World: TWorld); override;
    Procedure Act(); override;
  End;

  { TRock }

  TRock = Class(TBigRock)
  public
    Constructor create(); override;
  End;

  { TSpace }

  TSpace = Class(Tworld)
  private
    level: integer;
    counter: TCounter;
  public
    ShootsInGame: Integer;
    Constructor create(Parent: TOpenGLControl);
    Procedure CreateLevel;
    Procedure EndGame();
    Procedure Count(Points: integer);
    Procedure Act(); override;
  End;

  { TSpaceGunShoot }

  TSpaceGunShoot = Class(TActor)
  private
    pos: TVector2;
    speed: TVector2;
    lifetime: integer;
    worldwidth, worldheight: integer;
  public
    Constructor create(); override;
    Procedure addedToWorld(Const World: TWorld); override;
    Procedure act; override;
  End;

  { TEnemyGunShoot }

  TEnemyGunShoot = Class(TSpaceGunShoot)
  private
    Owner_: TActor;
  public
    Constructor create(); override;
    Procedure addedToWorld(Const World: TWorld); override;
    Procedure act; override;
  End;

  { TSpaceShip }

  TSpaceShip = Class(TActor)
  private
    shoots, GunReloadTimer, GunLoadTimer: Integer;
    blocker: boolean;
    img_boost, img_normal: TGreenfootImage;
    speed: TVector2;
    pos: TVector2;
    maxspeed: integer;
    worldwidth, worldheight: integer;
  public
    Constructor create(); override;
    Procedure addedToWorld(Const World: TWorld); override;
    Procedure Act(); override;
  End;

Implementation

{ TEnemyGunShoot }

Constructor TEnemyGunShoot.create;
Var
  img: TGreenfootImage;
Begin
  Inherited create;
  img := GreenFootGraphicEngine.FindImage('SpaceGunEnemyShoot');
  If Not assigned(img) Then Begin
    img := TGreenfootImage.Create(2, 16);
    img.BeginUpdate();
    img.SetColor(magenta);
    img.fillRect(0, 0, 2, 16);
    img.EndUpdate();
    GreenFootGraphicEngine.AddImage(img, 'SpaceGunEnemyShoot');
  End;
  setImage(img);
End;

Procedure TEnemyGunShoot.addedToWorld(Const World: TWorld);
Var
  dir: integer;
  spaceship: TEnemy;
Begin
  spaceship := TEnemy(Owner_);
  setRotation(spaceship.getRotation());
  pos := v2(getx, gety);
  dir := getRotation() + 90;
  speed := spaceship.speed;
  speed.x := speed.x + cos(degtorad(dir)) * 10;
  speed.y := speed.y + sin(degtorad(dir)) * 10;
  worldwidth := World.getWidth();
  worldheight := World.getHeight();
End;

Procedure TEnemyGunShoot.act;
Var
  rock: TActor;
Begin
  dec(lifetime);
  If lifetime > 0 Then Begin
    pos := pos + speed;
    setLocation(mod2(round(pos.x), worldwidth), mod2(round(pos.y), worldheight), False);
    // Alles was wir treffen können
    rock := getOneIntersectingObject(TSpaceShip);
    If assigned(rock) Then Begin
      getWorld().removeObject(self);
      getWorld().removeObject(rock);
      TSpace(Getworld()).EndGame();
    End;
  End
  Else Begin
    getWorld().removeObject(self);
  End;
End;

{ TCounter }

Constructor TCounter.Create;
Begin
  create('');
End;

Constructor TCounter.Create(prefix: String);
Var
  image: TGreenfootImage;
Begin
  Inherited Create;
  text := prefix;
  StringLength := (length(text) + 2) * 10;
  image := TGreenfootImage.Create(StringLength, 16);
  setimage(image);
  //image.free;
  updateImage();
End;

Destructor TCounter.destroy;
Begin
  getimage().free;
  Inherited destroy;
End;

Procedure TCounter.Increment(Value_: integer);
Begin
  value := value + Value_;
  UpdateImage();
End;

Procedure TCounter.UpdateImage;
Var
  image: TGreenfootImage;
Begin
  image := getimage();
  image.clear();
  image.SetColor(white);
  image.drawString(text + inttostr(value), 1, 12);
End;

{ TEnemy }

Constructor TEnemy.create;
Var
  img: TGreenfootImage;
Begin
  Inherited create;

  img := GreenFootGraphicEngine.FindImage('SpEnemy');
  If Not assigned(img) Then Begin
    img := TGreenfootImage.Create(30, 30);
    img.BeginUpdate();
    img.clear();
    img.SetColor(magenta);
    img.drawPolygon([5, 25, 15], [5, 5, 25], 3);
    img.drawLine(5, 5, 5, 15);
    img.drawLine(25, 5, 25, 15);
    img.EndUpdate();
    GreenFootGraphicEngine.AddImage(img, 'SpEnemy');
  End;
  setImage(img);
  GunLoadTimer := 50 + random(35); // Sonst schießen alle Gegner immer Gleichzeitig
End;

Procedure TEnemy.addedToWorld(Const World: TWorld);
Begin
  goal := world.getOneObject(TSpaceShip);
  pos := v2(getx, gety);
  speed := v2((random(10) - 5) / 2.5, (random(10) - 5) / 2.5);
  worldheight := world.getHeight();
  worldwidth := world.getWidth();
End;

Procedure TEnemy.Act;
Var
  dir, dx, dy: integer;
  shoot: TEnemyGunShoot;
Begin
  pos := pos + speed;
  setLocation(
    Mod2(round(pos.x), worldwidth),
    Mod2(round(pos.y), worldheight)
    , false);
  dx := getx - goal.getx;
  dy := gety - goal.gety;
  dir := round(radtodeg(arctan2(dy, dx))) + 90;
  setRotation(dir);
  If GunLoadTimer = 0 Then Begin
    GunLoadTimer := 50 + random(15);
    dir := -dx;
    dx := dy;
    dy := dir;
    dir := dx * dx + dy * dy;
    dx := round(10 * dx / sqrt(dir));
    dy := round(10 * dy / sqrt(dir));
    shoot := TEnemyGunShoot.create();
    shoot.Owner_ := self;
    getworld().addObject(shoot, getx + dx, gety + dy);
    shoot := TEnemyGunShoot.create();
    shoot.Owner_ := self;
    getworld().addObject(shoot, getx - dx, gety - dy);
  End;
  GunLoadTimer := max(0, GunLoadTimer - 1);
End;

{ TRock }

Constructor TRock.create;
Var
  img: TGreenfootImage;
  delta, r: single;
  xa, ya, x, y, ox, oy, i: integer;
  num: integer;
Begin
  Inherited create;
  num := random(10);
  img := GreenFootGraphicEngine.FindImage('Rock' + inttostr(num));
  If Not assigned(img) Then Begin
    img := TGreenfootImage.Create(25, 25);
    img.BeginUpdate();
    img.clear();
    delta := 360 / corners;
    r := random(10) - 5 + img.GetWidth Div 3;
    i := 0;
    xa := round(img.GetWidth / 2 + cos(degtorad(i * delta)) * r);
    ya := round(img.GetHeight / 2 + sin(degtorad(i * delta)) * r);
    ox := xa;
    oy := ya;
    img.SetColor(gray);
    For i := 1 To 9 Do Begin
      r := random(10) - 5 + img.GetWidth Div 3;
      x := round(img.GetWidth / 2 + cos(degtorad(i * delta)) * r);
      y := round(img.GetHeight / 2 + sin(degtorad(i * delta)) * r);
      img.drawLine(ox, oy, x, y);
      ox := x;
      oy := y;
    End;
    img.drawLine(ox, oy, xa, ya);
    img.EndUpdate();
    GreenFootGraphicEngine.AddImage(img, 'Rock' + inttostr(num));
  End;
  setImage(img);
End;

{ TBigRock }

Constructor TBigRock.create;
Var
  img: TGreenfootImage;
  delta, r: single;
  xa, ya, x, y, ox, oy, i: integer;
  num: integer;
Begin
  Inherited create;
  num := random(10);
  img := GreenFootGraphicEngine.FindImage('BigRock' + inttostr(num));
  If Not assigned(img) Then Begin
    img := TGreenfootImage.Create(50, 50);
    img.BeginUpdate();
    img.clear();
    delta := 360 / corners;
    r := random(10) - 5 + img.GetWidth Div 3;
    i := 0;
    xa := round(img.GetWidth / 2 + cos(degtorad(i * delta)) * r);
    ya := round(img.GetHeight / 2 + sin(degtorad(i * delta)) * r);
    ox := xa;
    oy := ya;
    img.SetColor(gray);
    For i := 1 To 9 Do Begin
      r := random(10) - 5 + img.GetWidth Div 3;
      x := round(img.GetWidth / 2 + cos(degtorad(i * delta)) * r);
      y := round(img.GetHeight / 2 + sin(degtorad(i * delta)) * r);
      img.drawLine(ox, oy, x, y);
      ox := x;
      oy := y;
    End;
    img.drawLine(ox, oy, xa, ya);
    img.EndUpdate();
    GreenFootGraphicEngine.AddImage(img, 'BigRock' + inttostr(num));
  End;
  setImage(img);
End;

Procedure TBigRock.addedToWorld(Const World: TWorld);
Begin
  pos := v2(getx, gety);
  speed := v2((random(10) - 5) / 2.5, (random(10) - 5) / 2.5);
  worldheight := world.getHeight();
  worldwidth := world.getWidth();
End;

Procedure TBigRock.Act;
Begin
  pos := pos + speed;
  setLocation(
    Mod2(round(pos.x), worldwidth),
    Mod2(round(pos.y), worldheight)
    , false);
End;

{ TSpaceGunShoot }

Constructor TSpaceGunShoot.create;
Var
  img: TGreenfootImage;
Begin
  Inherited create;
  img := GreenFootGraphicEngine.FindImage('SpaceGunShoot');
  If Not assigned(img) Then Begin
    img := TGreenfootImage.Create(2, 16);
    img.BeginUpdate();
    img.SetColor(yellow);
    img.fillRect(0, 0, 2, 16);
    img.EndUpdate();
    GreenFootGraphicEngine.AddImage(img, 'SpaceGunShoot');
  End;
  setImage(img);
  lifetime := 50;
End;

Procedure TSpaceGunShoot.addedToWorld(Const World: TWorld);
Var
  dir: integer;
  spaceship: TSpaceShip;
Begin
  spaceship := TSpaceShip(world.getOneObject(TSpaceShip)); // Das Parent Hohlen
  setRotation(spaceship.getRotation());
  pos := v2(getx, gety);
  dir := getRotation() + 90;
  speed := spaceship.speed;
  speed.x := speed.x + cos(degtorad(dir)) * 10;
  speed.y := speed.y + sin(degtorad(dir)) * 10;
  worldwidth := World.getWidth();
  worldheight := World.getHeight();
End;

Procedure TSpaceGunShoot.act;
Var
  rock: TActor;
  x, y: integer;
Begin
  dec(lifetime);
  If lifetime > 0 Then Begin
    pos := pos + speed;
    setLocation(mod2(round(pos.x), worldwidth), mod2(round(pos.y), worldheight), False);
    // Alles was wir treffen können
    rock := getOneIntersectingObject(TBigRock);
    If assigned(rock) Then Begin
      TSpace(getWorld()).ShootsInGame := TSpace(getWorld()).ShootsInGame - 1;
      getWorld().removeObject(self);
      x := rock.getx;
      y := rock.gety;
      getWorld().removeObject(rock);
      getWorld().addObject(TRock.create(), x, y);
      getWorld().addObject(TRock.create(), x, y);
      getWorld().addObject(TRock.create(), x, y);
      getWorld().addObject(TRock.create(), x, y);
      TSpace(Getworld()).Count(10);
    End;
    rock := getOneIntersectingObject(TRock);
    If assigned(rock) Then Begin
      TSpace(getWorld()).ShootsInGame := TSpace(getWorld()).ShootsInGame - 1;
      getWorld().removeObject(self);
      getWorld().removeObject(rock);
      TSpace(Getworld()).Count(15);
    End;
    rock := getOneIntersectingObject(TEnemy);
    If assigned(rock) Then Begin
      TSpace(getWorld()).ShootsInGame := TSpace(getWorld()).ShootsInGame - 1;
      getWorld().removeObject(self);
      getWorld().removeObject(rock);
      TSpace(Getworld()).Count(30);
    End;
  End
  Else Begin
    TSpace(getWorld()).ShootsInGame := TSpace(getWorld()).ShootsInGame - 1;
    getWorld().removeObject(self);
  End;
End;

{ TSpaceShip }

Constructor TSpaceShip.create;
Begin
  Inherited create;
  shoots := 0;
  blocker := false;
  GunLoadTimer := 0;
  maxspeed := 15;
  img_normal := GreenFootGraphicEngine.FindImage('img_normal');
  If Not assigned(img_normal) Then Begin
    img_normal := TGreenfootImage.Create(30, 40);
    img_normal.BeginUpdate();
    img_normal.clear();
    img_normal.SetColor(RED);
    // Antialiased Spaceship
    img_normal.drawPolygon([5, 15, 25, 15], [5, 15, 5, 25], 4);
    img_normal.drawPolygon([4, 15, 26, 15], [4, 16, 4, 26], 4);
    img_normal.EndUpdate();
    GreenFootGraphicEngine.AddImage(img_normal, 'img_normal');
  End;
  setImage(img_normal);
  // Draw the Boost
  img_boost := GreenFootGraphicEngine.FindImage('img_boost ');
  If Not assigned(img_boost) Then Begin
    img_boost := TGreenfootImage.Create(30, 40);
    img_boost.BeginUpdate();
    img_boost.clear();
    img_boost.drawImage(img_normal, 0, 0);
    img_boost.SetColor(yellow);
    img_boost.drawLine(10, 10, 8, 2);
    img_boost.drawLine(20, 10, 22, 2);
    img_boost.EndUpdate();
    GreenFootGraphicEngine.AddImage(img_boost, 'img_boost');
  End;
End;

Procedure TSpaceShip.addedToWorld(Const World: TWorld);
Begin
  worldheight := world.getHeight();
  worldwidth := world.getWidth();
  pos := v2(getx, gety);
  speed := v2(0, 0);
End;

Procedure TSpaceShip.Act;
Const
  Thrust = 0.5;
  ShootThrust = 0.5;
Var
  x, y, dir: integer;
  gunshot: TSpaceGunShoot;
Begin
  // Move
  If LenV2sqr(speed) >= sqr(ShootThrust) Then Begin
    pos := pos + speed;
    setLocation(Mod2(round(pos.x), worldwidth), mod2(round(pos.y), worldheight), false);
  End
  Else Begin
    speed := v2(0, 0);
  End;
  If isKeyDown(key_left) Then Begin
    setRotation(getRotation() - 5);
  End;
  If isKeyDown(key_right) Then Begin
    setRotation(getRotation() + 5);
  End;
  If isKeyDown(key_up) Then Begin
    dir := getRotation() + 90;
    speed.x := speed.x + (cos(degtorad(dir)) * Thrust);
    speed.y := speed.y + (sin(degtorad(dir)) * Thrust);
    If LenV2SQR(speed) > sqr(maxspeed) Then Begin
      speed := ScaleV2(maxspeed / LenV2(speed), speed);
    End;
    setImage(img_boost);
  End
  Else Begin
    //    speed := ScaleV2(0.99, speed); // To enable friction
    setImage(img_normal);
  End;
  //If isKeyDown(key_space) And (GunLoadTimer = 0) And (Not blocker) Then Begin // More Realistik
  If isKeyDown(key_space) And (TSpace(getWorld()).ShootsInGame < 10) And (GunLoadTimer = 0) Then Begin // Better for playing
    TSpace(getWorld()).ShootsInGame := TSpace(getWorld()).ShootsInGame + 1;
    dir := getRotation() + 90;
    speed.x := speed.x - (cos(degtorad(dir)) * ShootThrust);
    speed.y := speed.y - (sin(degtorad(dir)) * ShootThrust);
    GunReloadTimer := 35;
    GunLoadTimer := 5; // Die Zeit die es Dauert bis wieder geschossen werden kann
    inc(shoots);
    If Shoots >= 10 Then Begin
      Blocker := true;
    End;
    dir := getRotation() + 90;
    x := round(getx + (cos(degtorad(dir)) * 15));
    y := round(gety + (sin(degtorad(dir)) * 15));
    gunshot := TSpaceGunShoot.create();
    getWorld().addObject(gunshot, x, y);
  End;
  GunLoadTimer := max(0, GunLoadTimer - 1);
  GunReloadTimer := max(0, GunReloadTimer - 1);
  If (GunReloadTimer = 0) Then Begin
    Blocker := false;
    shoots := 0;
  End;
  // Alles was uns Umbringt
  If assigned(getOneIntersectingObject(TBigRock)) Then Begin
    getworld().removeObject(self);
    TSpace(getworld()).EndGame();
  End;
  If assigned(getOneIntersectingObject(TEnemy)) Then Begin
    getworld().removeObject(self);
    TSpace(getworld()).EndGame();
  End;
  If assigned(getOneIntersectingObject(TRock)) Then Begin
    getworld().removeObject(self);
    TSpace(getworld()).EndGame();
  End;
End;

{ TSpace }

Constructor TSpace.create(Parent: TOpenGLControl);
Begin
  Inherited create(Parent, 640, 480, 1);
  ShootsInGame := 0;
  counter := tcounter.create('Points : ');
  addObject(counter, 640 - 80, 480 - 35);
  level := 0;
  addObject(TSpaceShip.create(), 320, 240);
  SetSpeed(25);
  CreateLevel;
  Start();
End;

Procedure TSpace.CreateLevel;
Var
  sx, sy, y: integer;
  x: integer;
  i: integer;
  ship: TActor;
Begin
  ship := getOneObject(TSpaceShip);
  sx := ship.getx;
  sy := ship.gety;
  For i := 0 To 4 Do Begin
    x := Random(640);
    y := Random(480);
    While (x >= sx - 40) And (x <= sx + 40) Do Begin
      x := Random(640);
    End;
    While (y >= sy - 40) And (y <= sy + 40) Do Begin
      y := Random(480);
    End;
    addObject(TBigRock.create(), x, y);
  End;
  If level > 0 Then Begin
    For i := 0 To level - (level Mod 3) Do Begin
      x := Random(640);
      y := Random(480);
      While (x >= sx - 40) And (x <= sx + 40) Do Begin
        x := Random(640);
      End;
      While (y >= sy - 40) And (y <= sy + 40) Do Begin
        y := Random(480);
      End;
      addObject(TRock.create(), x, y);
    End;
  End;
  If level > 1 Then Begin
    // Einfügen von Gegnern
    For i := 0 To level - 2 Do Begin
      x := Random(640);
      y := Random(480);
      While (x >= sx - 40) And (x <= sx + 40) Do Begin
        x := Random(640);
      End;
      While (y >= sy - 40) And (y <= sy + 40) Do Begin
        y := Random(480);
      End;
      addObject(TEnemy.create(), x, y);
    End;
  End;
  inc(level);
End;

Procedure TSpace.EndGame;
Begin
  stop;
End;

Procedure TSpace.Count(Points: integer);
Begin
  counter.Increment(points);
End;

Procedure TSpace.Act;
Var
  enemies, rocks, bigrocks: TActor;
Begin
  // Wenns nichts mehr zum Abballern gibt
  rocks := getOneObject(TRock);
  bigrocks := getOneObject(TBigRock);
  enemies := getOneObject(TEnemy);
  If Not assigned(rocks)
    And
    Not assigned(bigrocks)
    And
    Not assigned(enemies) Then Begin
    CreateLevel;
  End;
End;

End.

