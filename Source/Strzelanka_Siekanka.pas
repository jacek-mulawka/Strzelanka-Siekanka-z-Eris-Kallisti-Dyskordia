unit Strzelanka_Siekanka;{28.02.2021}{24.04.2021}

  //
  // MIT License
  //
  // Copyright (c) 2021 Jacek Mulawka
  //
  // j.mulawka@interia.pl
  //
  // https://github.com/jacek-mulawka
  //

  //   +y         +z
  // +x  -x     /
  //   -y    -z

  //
  // TCel ( TGLDummyCube )
  //   element_widoczny_gl_scene_object
  //   modyfikator_rodzaj_gl_dummy_cube
  //     modyfikator_rodzaj_gl_scene_object
  //

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  Buttons, ComCtrls, Spin, windows, GLLCLViewer, GLScene, GLCadencer,
  GLCollision, GLSkydome, GLObjects, GLParticleFX, GLFireFX, GLThorFX,
  GLHUDObjects, GLWindowsFont, GLVectorGeometry, GLGeomObjects, GLPolyhedron,
  GLColor, GLBehaviours, GLMirror, GLSound, GLSMOpenAL, GLBaseClasses,
  GLKeyboard, DateUtils, IniFiles;

type
  TDzwiek_Rodzaj = ( dr_Brak, dr_Modyfikator, dr_Pa );
  TModyfikator_Rodzaj = ( mr_Brak, mr_Cele_Czesciej, mr_Cele_Rzadziej, mr_Cele_Szybciej, mr_Cele_Wolniej, mr_Karabin_Maszynowy, mr_Magazynek_Wiekszy );
  TMega_Element_Etap = ( mee_Brak, mee_Oczyszczanie_Planszy, mee_Runda_Zakonczona, mee_Tworzony, mee_W_Grze );
  TMega_Element_Ruch = ( mer_Brak, mer_Opadanie, mer_Uniki );
  TMiecz_Chowanie_Sie_Etap = ( mche_Brak, mche_Efekty_Neutralizuj, mche_Gotowy, mche_Obrot_Do_Pozycji__Ostrze_W_Gore, mche_Obrot_Do_Pozycji__Rekojesc_W_Przod, mche_Ruch_Do_Pozycji );
  TMiecz_Dobycie_Etap = ( mde_Brak, mde_Chowa_Sie, mde_Dobyty, mde_Dobywa_Sie, mde_Runda_Zakonczona, mde_Tworzony, mde_Schowany );

  TCel = class( TGLDummyCube )
  private
    { Private declarations }
    mega_element_skladnik, // Cel jest składnikiem mega elementu.
    trafienie_mieczem, // Cel został pokonany mieczem.
    usunac_cel
     : boolean;
    rozmiar_poziomy : smallint; // Ile razy po rozpadzie utworzy mniejsze elementy.
    utworzenie_czas : double;
    modyfikator_rodzaj : TModyfikator_Rodzaj;
    miecz_predkosc_affine_vektor : TAffineVector; // Prędkość miecza podczas trafienia.
    modyfikator_rodzaj_gl_dummy_cube : TGLDummyCube;
    element_widoczny_gl_scene_object,
    modyfikator_rodzaj_gl_scene_object
      : TGLSceneObject;
  public
    { Public declarations }
    constructor Create( AOwner : TComponent; AParent : TGLBaseSceneObject; const rozmiar_poziomy_f : smallint; const x_f, y_f, ekran_margines_boki_f, ekran_margines_gora_dol_f : real; const trafienie_mieczem_f : boolean; const z_f : integer = -1; const mega_element_poziom_f : integer = -1 );
    destructor Destroy(); override;
    procedure Skala_Ustaw();
  end;

  TPocisk = class( TGLSphere )
  private
    { Private declarations }
    karabin_maszynowy_pocisk,
    usunsc_pocisk
      : boolean;
    utworzenie_czas : double;
  public
    { Public declarations }
    constructor Create( AOwner : TComponent );
    //destructor Destroy(); override;
  end;

  { TStrzelanka_Siekanka_Form }

  TStrzelanka_Siekanka_Form = class ( TForm )
    Miecz_Przed_Jelec_GLFrustrum: TGLFrustrum;
    Klawisz_Dodatkowy__Miecz_Dobycie_Edit: TEdit;
    Klawisz_Dodatkowy__Miecz_Dobycie_Etykieta_Label: TLabel;
    Miecz_Dobycie_GLHUDText: TGLHUDText;
    Miecz_Dobycie_GLHUDSprite: TGLHUDSprite;
    Miecz_Rekojesc_Koncowka_GLCylinder: TGLCylinder;
    Miecz_Rekojesc_GLCylinder: TGLCylinder;
    Miecz_Jelec_GLCylinder: TGLCylinder;
    Miecz_Ostrze_GLCylinder: TGLCylinder;
    Miecz_Czubek_GLFrustrum: TGLFrustrum;
    Miecz_GLCube: TGLCube;
    Miecz_Kontener_GLDummyCube: TGLDummyCube;
    Logo_Image: TImage;
    Przeladowania_Dzwieki_Emiter_GLDummyCube: TGLDummyCube;
    GLSMOpenAL1: TGLSMOpenAL;
    Gra_GLSoundLibrary: TGLSoundLibrary;
    Klawisz_Dodatkowy__Przeladowanie_Edit: TEdit;
    Klawisz_Dodatkowy__Strzal_Edit: TEdit;
    Klawisz_Dodatkowy__Strzal_Etykieta_Label1: TLabel;
    Klawisz_Dodatkowy__Przeladowanie_Etykieta_Label: TLabel;
    Glosnosc_Etykieta_Label: TLabel;
    Mega_Element_Rundy_Label: TLabel;
    Opis_Label: TLabel;
    Magazynek_Wyswietlaj_CheckBox: TCheckBox;
    Glosnosc_SpinEdit: TSpinEdit;
    Miecz_Dobycie_CheckBox: TCheckBox;
    Miecz_Dobycie_Wielkosc_Etykieta_Label: TLabel;
    Miecz_Dobycie_Wielkosc_SpinEdit: TSpinEdit;
    Ustawienia_ScrollBox: TScrollBox;
    Statystyki_Wyswietlaj_CheckBox: TCheckBox;
    Start_Z_Pauza_CheckBox: TCheckBox;
    Ustawienia_Wczytaj_BitBtn: TBitBtn;
    Ukryte_Funkcje_Zezwalaj_CheckBox: TCheckBox;
    Mysz_Ciagle_Strzelanie_CheckBox: TCheckBox;
    Mega_Element_CheckBox: TCheckBox;
    Przeladowanie_Klikniecie_Wielkosc_Etykieta_Label: TLabel;
    Przeladowanie_Klikniecie_CheckBox: TCheckBox;
    Pomoc_Label: TLabel;
    PageControl1: TPageControl;
    Przeladowanie_Klikniecie_GLHUDText: TGLHUDText;
    Przeladowanie_Klikniecie_GLHUDSprite: TGLHUDSprite;
    Nowa_Gra_BitBtn: TBitBtn;
    Pauza_BitBtn: TBitBtn;
    Pomoc_BitBtn: TBitBtn;
    Pelny_Ekran_BitBtn: TBitBtn;
    Pomoc_Timer: TTimer;
    O_Programie_Splitter: TSplitter;
    O_Programie_TabSheet: TTabSheet;
    Pomoc_TabSheet: TTabSheet;
    Przeladowanie_Klikniecie_Wielkosc_SpinEdit: TSpinEdit;
    Ustawienia_TabSheet: TTabSheet;
    Ustawienia_Zapisz_BitBtn: TBitBtn;
    Zamknij_BitBtn: TBitBtn;
    Celownicza_Linia_GLLines: TGLLines;
    Pomoc_GLHUDText: TGLHUDText;
    Pomoc_GLHUDSprite: TGLHUDSprite;
    Mega_Element_Kontener_GLDummyCube: TGLDummyCube;
    Mega_Element_GLThorFXManager: TGLThorFXManager;
    Mega_Element_Efekt_GLDummyCube: TGLDummyCube;
    Karabin_Maszynowy_GLFireFXManager: TGLFireFXManager;
    GLParticleFXRenderer1: TGLParticleFXRenderer;
    Predkosci_GLFireFXManager: TGLFireFXManager;
    Pocisk_GLFireFXManager: TGLFireFXManager;
    Magazynek_Wiekszy_GLFireFXManager: TGLFireFXManager;
    O_Programie_Label: TLabel;
    Magazynek_GLHUDSprite: TGLHUDSprite;
    Magazynek_GLHUDText: TGLHUDText;
    Przeladuj_GLHUDSprite: TGLHUDSprite;
    Przeladuj_GLHUDText: TGLHUDText;
    Statystyki_GLHUDSprite: TGLHUDSprite;
    Gra_Elementy_GLDummyCube: TGLDummyCube;
    Statystyki_GLWindowsBitmapFont: TGLWindowsBitmapFont;
    Statystyki_GLHUDText: TGLHUDText;
    Lewo_GLSphere: TGLSphere;
    Gra_GLSkyDome: TGLSkyDome;
    Gra_GLCadencer: TGLCadencer;
    Gra_GLCamera: TGLCamera;
    Gra_GLCollisionManager: TGLCollisionManager;
    Gra_GLLightSource: TGLLightSource;
    Gra_GLScene: TGLScene;
    Gra_GLSceneViewer: TGLSceneViewer;
    Przeladuj_GLWindowsBitmapFont: TGLWindowsBitmapFont;
    Ekran_Margines_Wylicz_Timer: TTimer;
    Zero_GLSphere: TGLSphere;
    procedure FormCreate( Sender: TObject );
    procedure FormShow( Sender: TObject );
    procedure FormClose( Sender: TObject; var CloseAction: TCloseAction );
    procedure FormResize( Sender: TObject );

    procedure Ekran_Margines_Wylicz_TimerTimer(Sender: TObject);
    procedure Pomoc_TimerTimer( Sender: TObject );

    procedure Gra_GLSceneViewerKeyDown( Sender: TObject; var Key: Word; Shift: TShiftState );
    procedure Gra_GLSceneViewerMouseDown( Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer );
    procedure Gra_GLSceneViewerMouseMove( Sender: TObject; Shift: TShiftState; X, Y: Integer );
    procedure Gra_GLSceneViewerMouseLeave( Sender: TObject );

    procedure Nowa_Gra_BitBtnClick( Sender: TObject );
    procedure Pauza_BitBtnClick( Sender: TObject );
    procedure Pelny_Ekran_BitBtnClick( Sender: TObject );
    procedure Pomoc_BitBtnClick( Sender: TObject );
    procedure Glosnosc_SpinEditChange( Sender: TObject );
    procedure Klawisz_Dodatkowy__EditKeyDown( Sender: TObject; var Key: Word; Shift: TShiftState );
    procedure Mega_Element_CheckBoxClick( Sender: TObject );
    procedure Wyswietlanie_CheckBoxClick( Sender: TObject );

    procedure Ustawienia_Wczytaj_BitBtnClick( Sender: TObject );
    procedure Ustawienia_Zapisz_BitBtnClick( Sender: TObject );

    procedure Gra_GLCadencerProgress( Sender: TObject; const deltaTime, newTime: Double );
    procedure Gra_GLCollisionManagerCollision( Sender: TObject; object1, object2: TGLBaseSceneObject );
  private
    karabin_maszynowy__aktywnosc_g : boolean;

    magazynek__pojemnosc_g : smallint;

    dzwieki__modyfikator_ilosc_g, // Ilość dźwięków modyfikatorów.
    dzwieki__pa_ilosc_g, // Ilość dźwięków trafień.
    elementy_nie_zestrzelone_ilosc_g, // Ilu elementom udało się uciec.
    elementy_wszystkie_ilosc_g, // Wszystkie utworzone elementy.
    karabin_maszynowy__magazynek__mnoznik_g,
    magazynek__mnoznik_g,
    magazynek__pociski_ilosc_g,
    magazynek__przeladowania_ilosc_g,
    mega_element__pojawienie_sie_ilosc_g,
    mega_element__poziom_g, // Ile razy już wystąpił mega element.
    mega_element__poziom__poczatkowe_g, // Początkowa wartość ustawiana przy starcie nowej gry.
    mega_element__trafienia_licznik_g, // Ilość trafień od ostatniego wystąpienia mega elementu (elementy z modyfikatorami nie wpływają na tą wartość).
    pelny_ekran__ilosc_zmian_g, // TGLArrowArc znika gdy zmieni się tryb ekranu na pełny albo odwrotnie. Zlicza ile było zmian trybu ekranu (zwiększa wartość) i ile przywróceń widoczności elementów (zmniejsza wartość).
    strzaly_ilosc_g,
    trafienia_ilosc_g,
    trafienia_ilosc_miecz_g
      : integer;

    cel__czas_trwania_sekundy_g, // Po jakim czasie od utworzenia zwolnić cel.
    cel__dystans_trwania_g, // Po oddalenie się na jaką odległość zwolnić element.
    cel__ostatnio_utworzony_czas_g, // Data czas ostatniego utworzenia celu.
    karabin_maszynowy__trwanie_sekundy_g, // Czas trwania trybu karabinu maszynowego.
    karabin_maszynowy__utworzenie_czas_g, // Data czas ostatniej modyfikacji karabinu maszynowego.
    magazynek__mnoznik__trwanie_sekundy_g, // Czas trwania mnożnika magazynka.
    magazynek__mnoznik__utworzenie_czas_g, // Data czas ostatniej modyfikacji mnożnika magazynka.
    magazynek__przeladowanie__trwanie_sekundy_g, // Czas trwania wymiany magazynka.
    magazynek__przeladowanie__rozpoczecie_czas_g, // Czas rozpoczęcia przeładowania magazynka.
    mega_element__czas_trwania_sekundy_g, // Po jakim czasie od utworzenia zwolnić element mega elementu.
    mega_element__runda_czas__rozpoczecia_g, // Czas wejścia mega elementu do gry w danej rundzie.
    mega_element__runda_czas__zakonczenia_g, // Czas zakończenia danej rundy z mega elementem.
    mega_element__ulatwienie__czas_dodania_kolejnego_sekundy_g, // Po jakim czasie zostanie dodane kolejne ułatwienia gdy mega element jest widoczny.
    mega_element__ulatwienie__ostatnie_czas_g, // Data czas ostatniego ułatwienia gdy mega element jest widoczny.
    mega_element__unik_ostatni_czas_g, // Data czas ostatniego uniku mega elementu.
    pocisk__czas_trwania_sekundy_g, // Po jakim czasie od utworzenia zwolnić element.
    pocisk__dystans_trwania_g, // Po oddalenie się na jaką odległość zwolnić element.
    pocisk__ostatnio_utworzony_czas_g, // Jest tożsame z czasem przeładowania pocisku w lufie.
    pocisk__przeladowanie_trwanie_g, // Czas przeładowania jednego pocisku po strzale.
    pocisk__ruch_szybkosc_g // Szybkość ruchu elementu.
      : double;

    cel__czas_dodania_kolejnego_sekundy_g, // Po jakim czasie zostanie dodany kolejny cel.
    cel__czas_dodania_kolejnego_sekundy__modyfikator_wplyw_g, // Jak bardzo modyfikator wpływa na częstotliwość pojawiania się celów.
    cel__czas_dodania_kolejnego_sekundy__poczatkowe_g, // Początkowa wartość ustawiana przy starcie nowej gry.
    cel__ruch_szybkosc_g, // Szybkość ruchu elementu.
    cel__ruch_szybkosc__modyfikator_wplyw_g, // Jak bardzo modyfikator wpływa na zmianę szybkości ruchu celów.
    cel__ruch_szybkosc__poczatkowe_g, // Początkowa wartość ustawiana przy starcie nowej gry.
    ekran_margines__boki_g, // Współrzędna x dodatnia, która określa (z pewnym zapasem) poza jaką wartością x elementy nie będą widoczne na ekranie (po bokach).
    ekran_margines__gora_dol_g, // Współrzędna y dodatnia, która określa (z pewnym zapasem) poza jaką wartością y elementy nie będą widoczne na ekranie (u góry i u dołu).
    ekran_margines__istnienie__gora_dol_g, // Współrzędna y dodatnia, która określa (z pewnym zapasem) poza jaką wartością y elementy będą tworzone (u góry +y) i zwalniane (u dołu -y).
    mega_element__czas_uniku_kolejnego_sekundy_g, // Po jakim czasie zostanie zastosowany kolejny unik mega elementu.
    mega_element__pojawienie_sie_postep_procent_g // Postęp do pojawienia się mega elementu wyrażony w procencie.
      : real;

    magazynek__przeladowywanie_w_trakcie, // Czy jest w trakcie przeładowywania magazynka.
    miecz_dzwiek_lot_pauza_g
      : boolean;

    pomoc_oczekiwanie_rozpoczecie_data_czas : TDateTime; // Data czas rozpoczęcia oczekiwania na wyświetlenie panelu pomocy.

    przeladowania_dzwiek_pauza_g : string; // Zapamiętuje, który dźwięk przeładowań był odtwarzany w momencie włączania pauzy.

    pelny_ekran__zapamietane__pozycja,
    pelny_ekran__zapamietane__rozmiar
      : TPoint;

    dzwieki__rodzaj_list, // Lista dźwięków trafienia.
    cele_list,
    pociski_list
      : TList;

    mega_element__etap_g : TMega_Element_Etap;
    mega_element__ruch_g : TMega_Element_Ruch;
    miecz_chowanie_sie_etap : TMiecz_Chowanie_Sie_Etap;
    miecz_dobycie_etap_g : TMiecz_Dobycie_Etap;

    procedure Nowa_Gra();
    procedure Pauza( const czy_pauza_f : variant );
    procedure Pelny_Ekran( const czy_pelny_wkran_f : variant );

    procedure Ekran_Margines_Wylicz();

    function Cele__Dodaj_Jeden( const rozmiar_poziomy_f : smallint; const x_f, y_f : real; const trafienie_mieczem_f : boolean = false ) : TCel;
    procedure Cele__Zwolnij_Jeden( cel_f : TCel  );
    procedure Cele__Zwolnij_Wszystkie();
    procedure Cele__Ruch( delta_czasu_f : double );

    procedure Pociski__Dodaj_Jeden( const kierunek_vektor_f : TAffineVector );
    procedure Pociski__Zwolnij_Jeden( pocisk_f : TPocisk  );
    procedure Pociski__Zwolnij_Wszystkie();
    procedure Pociski__Ruch( delta_czasu_f : double );

    procedure Miecz__Kolizji_Elementy__Dodaj();
    procedure Miecz__Kolizji_Elementy__Zwolnij_Wszystkie();
    procedure Miecz_Ruch( delta_czasu_f : double );

    procedure Dzwieki__Rodzaj__Dodaj_Jeden( const x_f, y_f : real; const dzwiek_rodzaj_f : TDzwiek_Rodzaj );
    procedure Dzwieki__Rodzaj__Zwolnij_Wszystkie();

    procedure Napis_Odswiez( const oczekiwanie_pomin_f : boolean = false );
    procedure Przeladuj_Dzwiek_Ustaw( const dzwiek_nazwa_f : string );
    procedure Przeladuj_Komunikat_Ustaw( const widocznosc_f : boolean );

    procedure Cel__Czas_Dodania_Kolejnego_Zmien( const zwiekszenie_f : boolean );
    procedure Cel__Ruch_Szbkosc_Zmien( const zwiekszenie_f : boolean );

    procedure Karabin_Maszynowy_Zmien( const aktywny_f : boolean );
    procedure Magazynek__Mnoznik_Zmien( const kierunek_f : smallint );

    procedure Mega_Element_Efekt_Wylicz();
    procedure Mega_Element_Zatrzymaj();

    procedure Ustawienia_Plik( const zapisuj_ustawienia_f : boolean = false );

    procedure Klawisz_Dodatkowy__Nazwa_Ustal( const edit_f : TEdit );

    procedure Dzwieki_Wczytaj();

    function Sekundy_W_Czas_W_Minutach( sekundy_f : double ) : string;
  public
  end;

const
  dzwieki__prefiks__mega_element_c : string = 'Mega element.wav';
  dzwieki__prefiks__miecz__lot_c : string = 'Miecz.wav';
  dzwieki__prefiks__modyfikator_c : string = 'Modyfikator ';
  dzwieki__prefiks__pa_c : string = 'Pa ';
  dzwieki__prefiks__pociski_c : string = 'Pociski.wav';
  dzwieki__prefiks__pociski__karabin_maszynowy_c : string = 'Pociski karabin maszynowy.wav';
  dzwieki__prefiks__przeladowano_c : string = 'Przeładowano.wav';
  dzwieki__prefiks__przeladowywanie_c : string = 'Przeładowywanie.wav';
  dzwieki__prefiks__przeladuj_c : string = 'Przeładuj.wav';

  miecz_kolizje_elementy_nazwa_prefiks_c : string = 'Miecz_Kolizje_Elementy__';

  sila_wspolczynnik_staly_c : double = 0.025;

var
  Strzelanka_Siekanka_Form: TStrzelanka_Siekanka_Form;

implementation

{$R *.lfm}

//Konstruktor klasy TCel.
constructor TCel.Create( AOwner : TComponent; AParent : TGLBaseSceneObject; const rozmiar_poziomy_f : smallint; const x_f, y_f, ekran_margines_boki_f, ekran_margines_gora_dol_f : real; const trafienie_mieczem_f : boolean; const z_f : integer = -1; const mega_element_poziom_f : integer = -1 );
var
  zti : smallint;
begin

  //
  // Parametry:
  //   AOwner
  //   rozmiar_poziomy_f:
  //     0 > - dodaje kolejny cel w miejscu rozpadu poprzedniego.
  //     <= 0 - dodaje niezależny cel.
  //   x_f
  //   y_f
  //   ekran_margines_boki_f - na jakim obszarze ekranu mogą pojawiać się cele
  //   ekran_margines_gora_dol_f - na jakiej wysokości są tworzone cele
  //   z_f:
  //     0 >= - dodaje mega element.
  //     < 0 - dodaje zwykły cel.
  //       gdy z_f < 0 i mega_element_poziom_f >= 0 dodaje ułatwienie (karabin maszynowy albo magazynek)
  //   mega_element_poziom_f - aktualna wielkość mega elementu
  //   trafienie_mieczem_f
  //

  inherited Create( AOwner );

  Self.Parent := AParent;
  //Self.VisibleAtRunTime := true; //???
  Self.usunac_cel := false;
  Self.trafienie_mieczem := false;
  Self.modyfikator_rodzaj_gl_dummy_cube := nil;
  Self.modyfikator_rodzaj_gl_scene_object := nil;

  GLVectorGeometry.MakeVector( Self.miecz_predkosc_affine_vektor, 0, 0, 0 );

  if z_f < 0 then
    begin

      // Dodaje zwykły cel albo ułatwienie.

      Self.mega_element_skladnik := false;

      Self.Direction.AsVector := GLVectorGeometry.VectorMake( 0, -1, 0 );
      Self.Position.Z := 10;

      {$region 'Obsługa zwykłego celu.'}
      if rozmiar_poziomy_f > 0 then
        begin

          // Tworzy kształt powstały w wyniku rozpadu istniejącego kształtu.

          Self.Position.X := x_f;
          Self.Position.Y := y_f;

          //if not trafienie_mieczem_f then
            Self.TurnAngle := Random( 91 ) - 45; // Modyfikuje kierunek lotu celu.

          Self.rozmiar_poziomy := rozmiar_poziomy_f;
          Self.modyfikator_rodzaj := mr_Brak;

        end
      else//if rozmiar_poziomy_f > 0 then
        begin

          // Tworzy nowy kształt.

          Self.Position.X :=
              ekran_margines_boki_f // Określa maksymalną szerokość (połowy) ekranu, na której mogą pojawiać się cele.
            * Random( 101 ) * 0.01; // Losuje procentową wartość wyliczonej szerokości.

          if Random( 2 ) = 0 then // Losuje czy cel będzie po ujemnej stronie współrzędnych.
            Self.Position.X := -Self.Position.X;

          Self.Position.Y := ekran_margines_gora_dol_f;


          Self.rozmiar_poziomy := Random( 3 ) + 1;


          // Tylko nowy cel może mieć modyfikatory.
          if mega_element_poziom_f < 0 then
            begin

              // Dodaje zwykły cel.

              zti := Random( 100 ) + 1;

              if zti = 100 then
                Self.modyfikator_rodzaj := mr_Karabin_Maszynowy
              else
              if zti >= 95 then
                Self.modyfikator_rodzaj := mr_Magazynek_Wiekszy
              else
              if zti <= 20 then // 20
                Self.modyfikator_rodzaj := TModyfikator_Rodzaj(Random( 4 ) + 1)
              else
                Self.modyfikator_rodzaj := mr_Brak;

            end
          else//if mega_element_poziom_f < 0 then
            begin

              // Dodaje ułatwienie.

              if Random( 2 ) = 1 then
                Self.modyfikator_rodzaj := mr_Karabin_Maszynowy
              else//if Random( 2 ) = 1 then
                Self.modyfikator_rodzaj := mr_Magazynek_Wiekszy;

            end;
          //---//if mega_element_poziom_f < 0 then
          //---// Tylko nowy cel może mieć modyfikatory.

        end;
      //---//if rozmiar_poziomy_f > 0 then



      if not ( Self.modyfikator_rodzaj in [ mr_Cele_Czesciej, mr_Cele_Rzadziej, mr_Cele_Szybciej, mr_Cele_Wolniej ] ) then
        begin

          // Dla tych modyfikatorów losuje kształt elementu.

          zti := Random( 10 ) + 1;
          //Strzelanka_Siekanka_Form.Caption := IntToStr( zti ); //???

          case zti of
              1 : Self.element_widoczny_gl_scene_object := TGLAnnulus.Create( Self );
              2 : Self.element_widoczny_gl_scene_object := TGLCapsule.Create( Self );
              3 : Self.element_widoczny_gl_scene_object := TGLCone.Create( Self );
              4 : Self.element_widoczny_gl_scene_object := TGLCube.Create( Self );
              5 : Self.element_widoczny_gl_scene_object := TGLCylinder.Create( Self ); // uses GLBaseClasses.
              6 : Self.element_widoczny_gl_scene_object := TGLDodecahedron.Create( Self ); // uses GLPolyhedron.
              7 : Self.element_widoczny_gl_scene_object := TGLFrustrum.Create( Self );
              8 : Self.element_widoczny_gl_scene_object := TGLSphere.Create( Self );
              9 : Self.element_widoczny_gl_scene_object := TGLTetrahedron.Create( Self ); // uses GLPolyhedron.
              10 : Self.element_widoczny_gl_scene_object := TGLTorus.Create( Self );
              else//case zti of
                begin
                  Self.element_widoczny_gl_scene_object := TGLSphere.Create( Self );
                end;
            end;
          //---//case zti of

          Self.Skala_Ustaw();


          Self.element_widoczny_gl_scene_object.PitchAngle := Random( 361 );
          Self.element_widoczny_gl_scene_object.RollAngle := Random( 361 );
          Self.element_widoczny_gl_scene_object.TurnAngle := Random( 361 );

        end
      else//if not ( Self.modyfikator_rodzaj in [ mr_Cele_Czesciej, mr_Cele_Rzadziej, mr_Cele_Szybciej, mr_Cele_Wolniej ] ) then
        begin

          // Dla tych modyfikatorów tworzy specjalny kształt elementu.

          Self.element_widoczny_gl_scene_object := TGLCube.Create( Self );

          Self.modyfikator_rodzaj_gl_dummy_cube := TGLDummyCube.Create( Self );
          Self.modyfikator_rodzaj_gl_dummy_cube.Parent := Self;
          Self.modyfikator_rodzaj_gl_dummy_cube.AbsoluteDirection := GLVectorGeometry.VectorMake( 0, 0, 1 );
          Self.modyfikator_rodzaj_gl_dummy_cube.AbsoluteUp := GLVectorGeometry.VectorMake( 0, 1, 0 );
          //Self.modyfikator_rodzaj_gl_dummy_cube.VisibleAtRunTime := true; //???
          //Self.modyfikator_rodzaj_gl_dummy_cube.EdgeColor.Color := clrGreen; //???

          case Self.modyfikator_rodzaj of // 2.
              mr_Cele_Czesciej, mr_Cele_Rzadziej :
                begin

                  Self.element_widoczny_gl_scene_object.Scale.X := 0.1;
                  Self.element_widoczny_gl_scene_object.Scale.Z := 2;


                  Self.modyfikator_rodzaj_gl_scene_object := TGLArrowArc.Create( Self.modyfikator_rodzaj_gl_dummy_cube );

                  if Self.modyfikator_rodzaj = mr_Cele_Czesciej then
                    Self.modyfikator_rodzaj_gl_scene_object.Turn( 180 );

                end;
              //---//mr_Cele_Czesciej, mr_Cele_Rzadziej :

              mr_Cele_Szybciej, mr_Cele_Wolniej :
                begin

                  Self.element_widoczny_gl_scene_object.Scale.X := 2;
                  Self.element_widoczny_gl_scene_object.Scale.Z := 0.1;


                  Self.modyfikator_rodzaj_gl_scene_object := TGLArrowLine.Create( Self.modyfikator_rodzaj_gl_dummy_cube );
                  Self.modyfikator_rodzaj_gl_scene_object.Pitch( 90 );

                  if Self.modyfikator_rodzaj = mr_Cele_Szybciej then
                    Self.modyfikator_rodzaj_gl_scene_object.Turn( 180 );

                end;
              //---//mr_Cele_Szybciej, mr_Cele_Wolniej :
            end;
          //---//case Self.modyfikator_rodzaj of // 2.

          Self.modyfikator_rodzaj_gl_scene_object.Parent := Self.modyfikator_rodzaj_gl_dummy_cube;
          Self.element_widoczny_gl_scene_object.Scale.Y := 0.1;
          //Self.modyfikator_rodzaj_gl_scene_object.ShowAxes := true; //???

        end;
      //---//if not ( Self.modyfikator_rodzaj in [ mr_Cele_Czesciej, mr_Cele_Rzadziej, mr_Cele_Szybciej, mr_Cele_Wolniej ] ) then
      {$endregion 'Obsługa zwykłego celu.'}

    end
  else//if z_f < 0 then
    begin

      // Dodaje mega element.

      Self.mega_element_skladnik := true;

      Self.rozmiar_poziomy := 1;

      Self.Position.X := x_f - mega_element_poziom_f * 0.5 - Self.rozmiar_poziomy * 0.5; // Wyśrodkowuje elementy względem kontenera po (bezwzględnej) osi X.
      Self.Position.Y := z_f; // * 0.5
      Self.Position.Z := -y_f + mega_element_poziom_f * 0.5 + Self.rozmiar_poziomy * 0.5; // Wyśrodkowuje elementy względem kontenera po (bezwzględnej) osi Y.

      Self.modyfikator_rodzaj := mr_Brak;

      Self.element_widoczny_gl_scene_object := TGLCube.Create( Self );

      Self.Skala_Ustaw();

      //Self.element_widoczny_gl_scene_object.Material.FrontProperties.Ambient.RandomColor();
      //Self.element_widoczny_gl_scene_object.Material.FrontProperties.Diffuse.Color := clrBlue;
      //Self.element_widoczny_gl_scene_object.Material.FrontProperties.Emission.Color := clrSkyBlue;

      //Self.element_widoczny_gl_scene_object.Material.FrontProperties.Ambient.RandomColor();
      //Self.element_widoczny_gl_scene_object.Material.FrontProperties.Diffuse.RandomColor();
      //Self.element_widoczny_gl_scene_object.Material.FrontProperties.Emission.Color := clrBlue;

    end;
  //---//if z_f < 0 then


  GetOrCreateInertia( Self.element_widoczny_gl_scene_object.Behaviours ).Mass := Self.rozmiar_poziomy;

  GetOrCreateInertia( Self.element_widoczny_gl_scene_object.Behaviours ).RotationDamping.SetDamping( 1, 2, 0 ); // Opcjonalne. // Dodatnie jakby spowalnia. // uses GLBehaviours.
  GetOrCreateInertia( Self.Behaviours ).TranslationDamping.SetDamping( 1.0, 0, 0.0 ); // Opcjonalne. // Dodatnie wyhamuje, ujemne przyśpiesza. // uses GLBehaviours.


  Self.element_widoczny_gl_scene_object.Parent := Self;

  Self.element_widoczny_gl_scene_object.Material.FrontProperties.Ambient.RandomColor();
  Self.element_widoczny_gl_scene_object.Material.FrontProperties.Diffuse.RandomColor();
  Self.element_widoczny_gl_scene_object.Material.FrontProperties.Emission.RandomColor();

  if Self.modyfikator_rodzaj_gl_dummy_cube <> nil then
    begin

      GetOrCreateInertia( Self.modyfikator_rodzaj_gl_dummy_cube.Behaviours ).Mass := 1;

      case Self.modyfikator_rodzaj of
          mr_Cele_Czesciej, mr_Cele_Rzadziej :
            GetOrCreateInertia( Self.modyfikator_rodzaj_gl_dummy_cube.Behaviours ).RotationDamping.SetDamping( 0, 1.25, 0 );
          mr_Cele_Szybciej, mr_Cele_Wolniej :
            GetOrCreateInertia( Self.modyfikator_rodzaj_gl_dummy_cube.Behaviours ).TranslationDamping.SetDamping( 0.75, 0, 0 );
        end;
      //---//case Self.modyfikator_rodzaj of

    end;
  //---//if Self.modyfikator_rodzaj_gl_dummy_cube <> nil then



  if Self.modyfikator_rodzaj_gl_scene_object <> nil then
    begin

      Self.modyfikator_rodzaj_gl_scene_object.Material.FrontProperties.Ambient := Self.element_widoczny_gl_scene_object.Material.FrontProperties.Ambient;
      Self.modyfikator_rodzaj_gl_scene_object.Material.FrontProperties.Diffuse := Self.element_widoczny_gl_scene_object.Material.FrontProperties.Diffuse;
      Self.modyfikator_rodzaj_gl_scene_object.Material.FrontProperties.Emission := Self.element_widoczny_gl_scene_object.Material.FrontProperties.Emission;

    end;
  //---//if Self.modyfikator_rodzaj_gl_scene_object <> nil then

end;//---//Konstruktor klasy TCel.

//Destruktor klasy TCel.
destructor TCel.Destroy();
begin

  FreeAndNil( Self.element_widoczny_gl_scene_object );

  if Self.modyfikator_rodzaj_gl_scene_object <> nil then
    FreeAndNil( Self.modyfikator_rodzaj_gl_scene_object );

  if Self.modyfikator_rodzaj_gl_dummy_cube <> nil then
    FreeAndNil( Self.modyfikator_rodzaj_gl_dummy_cube );

  inherited;

end;//---//Destruktor klasy TCel.

//Funkcja Skala_Ustaw().
procedure TCel.Skala_Ustaw();
var
  ztr : real;
begin

  if   ( Self.element_widoczny_gl_scene_object is TGLTetrahedron )
    or ( Self.element_widoczny_gl_scene_object is TGLCapsule )then
    ztr := Self.rozmiar_poziomy * 0.5 // Element jest większy niż pozostałe obiekty.
  else//if Self.element_widoczny_gl_scene_object is TGLTetrahedron then
    ztr := Self.rozmiar_poziomy;


  Self.element_widoczny_gl_scene_object.Scale.X := ztr;

  //if Self.mega_element_skladnik then
  //  Self.element_widoczny_gl_scene_object.Scale.Y := ztr * 0.5
  //else//if Self.mega_element_skladnik then
    Self.element_widoczny_gl_scene_object.Scale.Y := ztr;

  Self.element_widoczny_gl_scene_object.Scale.Z := ztr;

  //Self.element_widoczny_gl_scene_object.Scale.Scale( ztr ); // Nie może być tak, gdyż to skaluje aktualny rozmiar o zadaną wartość a nie bazowy rozmiar.


  if Self.modyfikator_rodzaj_gl_dummy_cube <> nil then
    begin

      // Aby element charakterystyczny niektórych modyfikatorów był przed elementem głównym (nie będą na siebie zachodzić).

      //Self.modyfikator_rodzaj_gl_dummy_cube.Position.X := ztr + ztr * 0.1; // Przesunięcie w lewo.
      //Self.modyfikator_rodzaj_gl_dummy_cube.Position.X := ztr; // Przesunięcie w lewo.
      Self.modyfikator_rodzaj_gl_dummy_cube.Position.Y := -ztr; // Przesunięcie w przód.

    end;
  //---//if Self.modyfikator_rodzaj_gl_dummy_cube <> nil then

end;//---//Funkcja Skala_Ustaw().

//Konstruktor klasy TPocisk.
constructor TPocisk.Create( AOwner : TComponent );
begin

  inherited Create( AOwner );

  Self.usunsc_pocisk := false;

end;//---//Konstruktor klasy TPocisk.

////Destruktor klasy TPocisk.
//destructor TPocisk.Destroy();
//begin
//
//  inherited;
//
//end;//---//Destruktor klasy TPocisk.


//      ***      Funkcje      ***      //

//Funkcja Nowa_Gra().
procedure TStrzelanka_Siekanka_Form.Nowa_Gra();
begin

  Cele__Zwolnij_Wszystkie();
  Pociski__Zwolnij_Wszystkie();

  cel__czas_dodania_kolejnego_sekundy_g := cel__czas_dodania_kolejnego_sekundy__poczatkowe_g;
  cel__ruch_szybkosc_g := cel__ruch_szybkosc__poczatkowe_g;
  karabin_maszynowy__aktywnosc_g := false;
  karabin_maszynowy__magazynek__mnoznik_g := 1;
  elementy_nie_zestrzelone_ilosc_g := 0;
  elementy_wszystkie_ilosc_g := 0;
  karabin_maszynowy__utworzenie_czas_g := Gra_GLCadencer.CurrentTime;
  magazynek__mnoznik_g := 1;
  magazynek__mnoznik__utworzenie_czas_g := Gra_GLCadencer.CurrentTime;
  magazynek__przeladowania_ilosc_g := 0;
  mega_element__czas_uniku_kolejnego_sekundy_g := 0.5;
  mega_element__etap_g := mee_Brak;
  mega_element__poziom_g := mega_element__poziom__poczatkowe_g;
  mega_element__ruch_g := mer_Opadanie;
  mega_element__trafienia_licznik_g := 0;
  mega_element__unik_ostatni_czas_g := Gra_GLCadencer.CurrentTime;
  miecz_dobycie_etap_g := mde_Brak;
  miecz_chowanie_sie_etap := mche_Brak;
  miecz_dzwiek_lot_pauza_g := false;
  przeladowania_dzwiek_pauza_g := '';
  strzaly_ilosc_g := 0;
  trafienia_ilosc_g := 0;
  trafienia_ilosc_miecz_g := 0;

  magazynek__pociski_ilosc_g := magazynek__pojemnosc_g * magazynek__mnoznik_g * karabin_maszynowy__magazynek__mnoznik_g;

  Mega_Element_GLThorFXManager.Vibrate := 0;
  Mega_Element_GLThorFXManager.Wildness := 0;

  Przeladuj_Dzwiek_Ustaw( '' );
  Przeladuj_Komunikat_Ustaw( false );

  Mega_Element_Efekt_Wylicz();
  Mega_Element_Zatrzymaj();


  //Miecz_Kontener_GLDummyCube.Position.X := 1;
  //Miecz_Kontener_GLDummyCube.Position.Y := -1;
  //Miecz_Kontener_GLDummyCube.Position.Z := -5;
  //Miecz_Kontener_GLDummyCube.PitchAngle := 90;
  //Miecz_Kontener_GLDummyCube.RollAngle := 180;
  //miecz_dobycie_etap_g := mde_Schowany;

  // Lub.


  Miecz_Kontener_GLDummyCube.ResetRotations();
  Miecz_Kontener_GLDummyCube.Direction.SetVector( 0, 0, 1 );
  Miecz_Kontener_GLDummyCube.Up.SetVector( 0, 1, 0 );

  if 1 = 10 then
    begin

      // Dobyty.

      Miecz_Kontener_GLDummyCube.Position.X := 0;
      Miecz_Kontener_GLDummyCube.Position.Y := 0;
      Miecz_Kontener_GLDummyCube.Position.Z := 10;
      Miecz_Kontener_GLDummyCube.TurnAngle := 90;
      Miecz_Kontener_GLDummyCube.PitchAngle := -90;
      miecz_dobycie_etap_g := mde_Dobyty;

    end
  else//if 1 = 10 then
    begin

      // Schowany.

      Miecz_Kontener_GLDummyCube.Position.X := 1;
      Miecz_Kontener_GLDummyCube.Position.Y := -1;
      Miecz_Kontener_GLDummyCube.Position.Z := -5;
      Miecz_Kontener_GLDummyCube.TurnAngle := 90;
      Miecz_Kontener_GLDummyCube.PitchAngle := 90;
      Miecz_Kontener_GLDummyCube.RollAngle := 180;
      miecz_dobycie_etap_g := mde_Schowany;

    end;
  //---//if 1 = 10 then


  //Miecz_Kontener_GLDummyCube.Position.X := 2.7; //???
  //Miecz_Kontener_GLDummyCube.Position.Y := 0;
  //Miecz_Kontener_GLDummyCube.Position.Z := 1;
  //Miecz_Kontener_GLDummyCube.RollAngle := 90;
  //Miecz_Kontener_GLDummyCube.PitchAngle := 90;
  //miecz_dobycie_etap_g := mde_Dobyty;


  Mega_Element_Rundy_Label.Caption :=
    #13 + #13 + #13 +
    'Rundy z mega elementem (numer rundy / czas trwania rundy)' + #13 +
    '[Rounds with a mega element (round number / round duration)]:.';

end;//---//Funkcja Nowa_Gra().

//Funkcja Pauza().
procedure TStrzelanka_Siekanka_Form.Pauza( const czy_pauza_f : variant );
var
  zti : smallint;
begin

  //
  // Funkcja ustawia pauzę.
  //
  // Parametry:
  //   czy_pauza_f:
  //     nil - przełącza pauzę.
  //     false - wyłącza pauzę.
  //     true - włącza pauzę.
  //


  if czy_pauza_f = true then
    Gra_GLCadencer.Enabled := false
  else
  if czy_pauza_f = false then
    Gra_GLCadencer.Enabled := true
  else
    Gra_GLCadencer.Enabled := not Gra_GLCadencer.Enabled;


  Napis_Odswiez( true );


  if Gra_GLCadencer.Enabled then
    begin

      // Gra.

      //Statystyki_GLHUDSprite.Height := 50;

      Pauza_BitBtn.Caption := '| |';

      Pomoc_Timer.Enabled := false;


      zti := Mega_Element_Kontener_GLDummyCube.Behaviours.IndexOfClass( TGLBSoundEmitter ); // -1 - brak, >= 0 zachowania.

      if    ( zti >= 0 )
        and ( ActiveSoundManager() <> nil ) then
        TGLBSoundEmitter(Mega_Element_Kontener_GLDummyCube.Behaviours.Items[ zti ]).Playing := mega_element__etap_g = mee_W_Grze;


      zti := Miecz_Kontener_GLDummyCube.Behaviours.IndexOfClass( TGLBSoundEmitter ); // -1 - brak, >= 0 zachowania.

      if    ( zti >= 0 )
        and ( ActiveSoundManager() <> nil ) then
        TGLBSoundEmitter(Miecz_Kontener_GLDummyCube.Behaviours.Items[ zti ]).Playing := miecz_dzwiek_lot_pauza_g;


      Przeladuj_Dzwiek_Ustaw( przeladowania_dzwiek_pauza_g ); // Przywraca odtwarzanie dźwięku przeładowań, który był odtwarzany w momencie włączania pauzy.

    end
  else//if Gra_GLCadencer.Enabled then
    begin

      // Pauza.

      zti := Mega_Element_Kontener_GLDummyCube.Behaviours.IndexOfClass( TGLBSoundEmitter ); // -1 - brak, >= 0 zachowania.

      if    ( zti >= 0 )
        and ( ActiveSoundManager() <> nil ) then
        TGLBSoundEmitter(Mega_Element_Kontener_GLDummyCube.Behaviours.Items[ zti ]).Playing := false;


      zti := Miecz_Kontener_GLDummyCube.Behaviours.IndexOfClass( TGLBSoundEmitter ); // -1 - brak, >= 0 zachowania.

      if    ( zti >= 0 )
        and ( ActiveSoundManager() <> nil ) then
        begin

          miecz_dzwiek_lot_pauza_g := TGLBSoundEmitter(Miecz_Kontener_GLDummyCube.Behaviours.Items[ zti ]).Playing;
          TGLBSoundEmitter(Miecz_Kontener_GLDummyCube.Behaviours.Items[ zti ]).Playing := false;

        end;
      //---//if    ( zti >= 0 ) (...)


      przeladowania_dzwiek_pauza_g := ''; // Jeżeli zapamiętany dźwięk po wyłączeniu pauzy już wybrzmiał to nie będzie go ponownie odtwarzać.

      if ActiveSoundManager() <> nil then //???
        for zti := 0 to Przeladowania_Dzwieki_Emiter_GLDummyCube.Behaviours.Count - 1 do
          if    ( Przeladowania_Dzwieki_Emiter_GLDummyCube.Behaviours.Items[ zti ].ClassType = TGLBSoundEmitter )
            and ( TGLBSoundEmitter(Przeladowania_Dzwieki_Emiter_GLDummyCube.Behaviours.Items[ zti ]).Playing ) then
            begin

              // Zapamiętuje, który dźwięk przeładowań był odtwarzany w momencie włączania pauzy.

              przeladowania_dzwiek_pauza_g := TGLBSoundEmitter(Przeladowania_Dzwieki_Emiter_GLDummyCube.Behaviours.Items[ zti ]).Source.SoundName;
              Break;

            end;
          //---//if    ( Przeladowania_Dzwieki_Emiter_GLDummyCube.Behaviours.Items[ zti ].ClassType = TGLBSoundEmitter ) (...)


      Przeladuj_Dzwiek_Ustaw( '' );


      Pauza_BitBtn.Caption := '>';

      FormResize( nil );


      Pomoc_Timer.Enabled := true;

    end;
  //---//if Gra_GLCadencer.Enabled then

end;//---//Funkcja Pauza().

//Funkcja Pelny_Ekran().
procedure TStrzelanka_Siekanka_Form.Pelny_Ekran( const czy_pelny_wkran_f : variant );
begin

  //
  // Funkcja ustawia pełny ekran.
  //
  // Parametry:
  //   czy_pelny_wkran_f:
  //     nil - przełącza pełny ekran.
  //     false - wyłącza pełny ekran.
  //     true - włącza pełny ekran.
  //

  inc( pelny_ekran__ilosc_zmian_g );

  Ekran_Margines_Wylicz_Timer.Tag := 1;


  if Self.WindowState <> wsMaximized then
    begin

      pelny_ekran__zapamietane__pozycja.X := Self.Left;
      pelny_ekran__zapamietane__pozycja.Y := Self.Top;

      pelny_ekran__zapamietane__rozmiar.X := Self.Width;
      pelny_ekran__zapamietane__rozmiar.Y := Self.Height;

    end;
  //---//if Self.WindowState <> wsMaximized then


  if czy_pelny_wkran_f = true then
    Self.WindowState := wsMaximized
  else
  if czy_pelny_wkran_f = false then
    Self.WindowState := wsNormal
  else
    if Self.WindowState = wsMaximized then
      Self.WindowState := wsNormal
    else//if Self.WindowState = wsMaximized then
      Self.WindowState := wsMaximized;


  if Self.WindowState = wsMaximized then
    begin

      Self.BorderStyle := bsNone;

      Self.BringToFront();

    end
  else//if Self.WindowState = wsMaximized then
    begin

      Self.BorderStyle := bsSizeable;


      Self.Left := pelny_ekran__zapamietane__pozycja.X;
      Self.Top := pelny_ekran__zapamietane__pozycja.Y;

      Self.Width := pelny_ekran__zapamietane__rozmiar.X;
      Self.Height := pelny_ekran__zapamietane__rozmiar.Y;

    end;
  //---//if Self.WindowState = wsMaximized then


  Ekran_Margines_Wylicz_Timer.Enabled := true;

end;//---//Funkcja Pelny_Ekran().

//Funkcja Ekran_Margines_Wylicz().
procedure TStrzelanka_Siekanka_Form.Ekran_Margines_Wylicz();
var
  zt_vektor : TVector;
  zt_progress_times : TProgressTimes; // uses GLBaseClasses.
begin

  //
  // Funkcja określa odległość współrzędnych poziomych od punktu zero, poza które nie powinny wlatywać elementy.
  //


  if Ekran_Margines_Wylicz_Timer.Tag <> 0 then
    Exit;


  //if Gra_GLSceneViewer.Buffer.ScreenVectorIntersectWithPlaneXY(  GLVectorGeometry.VectorMake( 1, 1, 0 ), 10, zt_vektor  ) then
  //  Caption := 'V ' + FloatToStr( zt_vektor.X ) + ' ' + FloatToStr( zt_vektor.Y ) + ' ' + FloatToStr( zt_vektor.Z )
  //else
  //  Caption := FloatToStr( zt_vektor.X ) + ' ' + FloatToStr( zt_vektor.Y ) + ' ' + FloatToStr( zt_vektor.Z );

  if Gra_GLSceneViewer.Buffer.ScreenVectorIntersectWithPlaneXY(  GLVectorGeometry.VectorMake( 1, 1, 0 ), 10, zt_vektor  ) then
    begin

      ekran_margines__boki_g := Abs( zt_vektor.X - zt_vektor.X * 0.1 ) - 2; // zt_vektor.X jest tutaj dodatni.
      ekran_margines__gora_dol_g := Abs( zt_vektor.Y - zt_vektor.Y * 0.1 ) - 2; // zt_vektor.Y jest tutaj ujemny.
      ekran_margines__istnienie__gora_dol_g := Abs( zt_vektor.Y + zt_vektor.Y * 0.1 ) + 2; // zt_vektor.Y jest tutaj ujemny.

      Mega_Element_Efekt_GLDummyCube.Position.X := zt_vektor.X + zt_vektor.X * 0.1 + 1;

    end
  else//if Gra_GLSceneViewer.Buffer.ScreenVectorIntersectWithPlaneXY(  GLVectorGeometry.VectorMake( 1, 1, 0 ), 10, zt_vektor  ) then
    begin

      ekran_margines__boki_g := Gra_GLSceneViewer.Width * 0.0075; // Określa maksymalną szerokość (połowy) ekranu, na której mogą pojawiać się cele.
      ekran_margines__gora_dol_g := Gra_GLSceneViewer.Height * 0.005;
      ekran_margines__istnienie__gora_dol_g := Gra_GLSceneViewer.Height * 0.015;

      Mega_Element_Efekt_GLDummyCube.Position.X := ekran_margines__boki_g;

    end;
  //---//if Gra_GLSceneViewer.Buffer.ScreenVectorIntersectWithPlaneXY(  GLVectorGeometry.VectorMake( 1, 1, 0 ), 10, zt_vektor  ) then


  //Caption := FloatToStr( zt_vektor.X ) + ' | ' + FloatToStr( zt_vektor.Y );


  if Gra_GLSceneViewer.Buffer.ScreenVectorIntersectWithPlaneXY(  GLVectorGeometry.VectorMake( 1, 1, 0 ), 20, zt_vektor  ) then
    begin

      Mega_Element_Efekt_GLDummyCube.Position.X := zt_vektor.X + zt_vektor.X * 0.1 + 1;

    end
  else//if Gra_GLSceneViewer.Buffer.ScreenVectorIntersectWithPlaneXY(  GLVectorGeometry.VectorMake( 1, 1, 0 ), 20, zt_vektor  ) then
    begin


      Mega_Element_Efekt_GLDummyCube.Position.X := ekran_margines__boki_g * 10;

    end;
  //---//if Gra_GLSceneViewer.Buffer.ScreenVectorIntersectWithPlaneXY(  GLVectorGeometry.VectorMake( 1, 1, 0 ), 20, zt_vektor  ) then

  Mega_Element_GLThorFXManager.Target.X := -2 * Mega_Element_Efekt_GLDummyCube.Position.X;
  //Mega_Element_GLThorFXManager.Maxpoints := Ceil( Gra_GLSceneViewer.Width * 0.2 );


  Mega_Element_Efekt_Wylicz();

  if not Gra_GLCadencer.Enabled then // Pauza.
    Mega_Element_GLThorFXManager.DoProgress( zt_progress_times ); // Aby podczas pauzy efekt nie kończył się w części ekranu gdy zmienia się wielkość okna.


  //Zero_GLSphere.Position.X := ekran_margines__boki_g;
  //Lewo_GLSphere.Position.X := ekran_margines__boki_g;
  //Zero_GLSphere.Position.Y := ekran_margines__gora_dol_g;
  //Zero_GLSphere.Position.Y := ekran_margines__istnienie__gora_dol_g;

  //Caption := {Caption +} ' | ' + FloatToStr( ekran_margines__boki_g ) + ' | ' + FloatToStr( ekran_margines__gora_dol_g ) + ' | ' + FloatToStr( ekran_margines__istnienie__gora_dol_g );
  //Caption := FloatToStr( Mega_Element_Efekt_GLDummyCube.Position.X ) + ' | ' + FloatToStr( Mega_Element_GLThorFXManager.Target.X );

end;//---//Funkcja Ekran_Margines_Wylicz().

//Funkcja Cele__Dodaj_Jeden().
function TStrzelanka_Siekanka_Form.Cele__Dodaj_Jeden( const rozmiar_poziomy_f : smallint; const x_f, y_f : real; const trafienie_mieczem_f : boolean = false ) : TCel;

  //Funkcja Cechy_Uzupelnij() w Cele__Dodaj_Jeden().
  procedure Cechy_Uzupelnij( const cel_f : TCel );
  begin

    // Funkcja uzupełnia cechy utworzonego celu o kolizje i efekty, dodaje cel do lisy celów, zwiększa licznik celów.


    if cel_f = nil then
      Exit;


    cel_f.utworzenie_czas := Gra_GLCadencer.CurrentTime;


    // Dynamiczne dodanie zdarzenia kolizji.
    with TGLBCollision.Create( cel_f.element_widoczny_gl_scene_object.Behaviours ) do
      begin

        GroupIndex := 0;
        BoundingMode := cbmSphere;
        Manager := Gra_GLCollisionManager;

      end;
    //---//with TGLBCollision.Create( cel_f.element_widoczny_gl_scene_object.Behaviours ) do

    if cel_f.modyfikator_rodzaj_gl_scene_object <> nil then
      with TGLBCollision.Create( cel_f.modyfikator_rodzaj_gl_scene_object.Behaviours ) do
        begin

          GroupIndex := 0;
          BoundingMode := cbmSphere;
          Manager := Gra_GLCollisionManager;

        end;
      //---//with TGLBCollision.Create( cel_f.modyfikator_rodzaj_gl_scene_object.Behaviours ) do
    //---// Dynamiczne dodanie zdarzenia kolizji.


    // Ustawia efekt wizualny modyfikatora.
    case cel_f.modyfikator_rodzaj of
        mr_Karabin_Maszynowy : TGLBFireFX(cel_f.AddNewEffect( TGLBFireFX )).Manager := Karabin_Maszynowy_GLFireFXManager;
        mr_Magazynek_Wiekszy : TGLBFireFX(cel_f.AddNewEffect( TGLBFireFX )).Manager := Magazynek_Wiekszy_GLFireFXManager;
        mr_Cele_Czesciej, mr_Cele_Rzadziej, mr_Cele_Szybciej, mr_Cele_Wolniej :
          TGLBFireFX(cel_f.AddNewEffect( TGLBFireFX )).Manager := Predkosci_GLFireFXManager;
      end;
    //---//case cel_f.modyfikator_rodzaj of



    cele_list.Add( cel_f );

    inc( elementy_wszystkie_ilosc_g );

  end;//---//Funkcja Cechy_Uzupelnij() w Cele__Dodaj_Jeden().

var
  x_l,
  y_l,
  z_l
    : integer;
begin//Funkcja Cele__Dodaj_Jeden().

  //
  // Parametry:
  //   rozmiar_poziomy_f:
  //     0 > - dodaje kolejny cel w miejscu rozpadu poprzedniego.
  //     <= 0 - dodaje niezależny cel.
  //   x_f
  //   y_f
  // trafienie_mieczem_f - gdy jest to cel utworzony w miejscu rozpadu poprzedniego to czy poprzedni cel został trafiony mieczem.
  //

  Result := nil;


  if   ( cele_list = nil )
    or (  not Assigned( cele_list )  ) then
    Exit;


  if rozmiar_poziomy_f <= 0 then
    begin

      {$region 'Obsługa mega elementu.'}
      if    ( mega_element__etap_g = mee_Brak )
        and ( mega_element__trafienia_licznik_g >= mega_element__pojawienie_sie_ilosc_g ) then
        begin

          mega_element__etap_g := mee_Oczyszczanie_Planszy;

          Mega_Element_GLThorFXManager.Vibrate := 0.05;
          Mega_Element_GLThorFXManager.Wildness := 0.15;


          Exit;

        end
      else//if    ( mega_element__etap_g = mee_Brak ) (...)
      if mega_element__etap_g = mee_Oczyszczanie_Planszy then
        begin

          if cele_list.Count > 0 then
            Exit; // Czeka aż wszystkie elementy znikną.

          Mega_Element_GLThorFXManager.Vibrate := 0;
          Mega_Element_GLThorFXManager.Wildness := 1000;

          mega_element__etap_g := mee_Tworzony;
          mega_element__ruch_g := mer_Opadanie;
          mega_element__trafienia_licznik_g := 0;
          inc( mega_element__poziom_g );

          Mega_Element_Zatrzymaj();

          Mega_Element_Kontener_GLDummyCube.ResetRotations();
          Mega_Element_Kontener_GLDummyCube.Position.X := 0;
          Mega_Element_Kontener_GLDummyCube.Position.Y := ekran_margines__istnienie__gora_dol_g + mega_element__poziom_g;
          //Mega_Element_Kontener_GLDummyCube.Position.Y := 0;
          Mega_Element_Kontener_GLDummyCube.Direction.AsVector := GLVectorGeometry.VectorMake( 0, -1, 0 );


          for x_l := 1 to mega_element__poziom_g do
            for y_l := 1 to mega_element__poziom_g do
              for z_l := 1 to mega_element__poziom_g do
                begin
                                                                                         // rozmiar_poziomy_f
                  Result := TCel.Create( Application, Mega_Element_Kontener_GLDummyCube, 1, x_l, y_l, ekran_margines__boki_g, ekran_margines__istnienie__gora_dol_g, trafienie_mieczem_f, z_l - 1, mega_element__poziom_g );

                  Cechy_Uzupelnij( Result );

                end;
              //---//for z_l := 1 to mega_element__poziom_g + 3 do


          mega_element__runda_czas__rozpoczecia_g := Gra_GLCadencer.CurrentTime;
          mega_element__runda_czas__zakonczenia_g := Gra_GLCadencer.CurrentTime;
          mega_element__ulatwienie__ostatnie_czas_g := Gra_GLCadencer.CurrentTime;
          mega_element__unik_ostatni_czas_g := Gra_GLCadencer.CurrentTime;

          mega_element__etap_g := mee_W_Grze;


          x_l := Mega_Element_Kontener_GLDummyCube.Behaviours.IndexOfClass( TGLBSoundEmitter ); // -1 - brak, >= 0 zachowania. // Tutaj tymczasowo jako indeks zachowania.

          if    ( x_l >= 0 )
            and ( ActiveSoundManager() <> nil ) then
            TGLBSoundEmitter(Mega_Element_Kontener_GLDummyCube.Behaviours.Items[ x_l ]).Playing := true;


          Exit;

        end
      else//if mega_element__etap_g = mee_Oczyszczanie_Planszy then
      if mega_element__etap_g = mee_W_Grze then
        begin

          if Gra_GLCadencer.CurrentTime - mega_element__ulatwienie__ostatnie_czas_g >= mega_element__ulatwienie__czas_dodania_kolejnego_sekundy_g then
            begin

              // Gdy mega element jest zbyt mocny dla gracza zostanie dodane ułatwienie.

              mega_element__ulatwienie__ostatnie_czas_g := Gra_GLCadencer.CurrentTime;
                                                                                                                                                                                             //z_f
              Result := TCel.Create( Application, Gra_Elementy_GLDummyCube, rozmiar_poziomy_f, x_f, y_f, ekran_margines__boki_g, ekran_margines__istnienie__gora_dol_g, trafienie_mieczem_f, -1, mega_element__poziom_g );

              Cechy_Uzupelnij( Result );

            end;
          //---//if Gra_GLCadencer.CurrentTime - mega_element__ulatwienie__ostatnie_czas_g >= mega_element__ulatwienie__czas_dodania_kolejnego_sekundy_g then


          if Mega_Element_Kontener_GLDummyCube.Count <= 0 then
            begin

             // Mega element przeminął.

             mega_element__etap_g := mee_Runda_Zakonczona;


             mega_element__runda_czas__zakonczenia_g := Gra_GLCadencer.CurrentTime;

             Mega_Element_GLThorFXManager.Wildness := 0;
             //Mega_Element_Efekt_Wylicz();

             Mega_Element_Zatrzymaj();

             // Wpisuje statystyki rund z mega elementem.
             Mega_Element_Rundy_Label.Caption := Copy( Mega_Element_Rundy_Label.Caption, 1, Length( Mega_Element_Rundy_Label.Caption ) - 1 ); // Usuwa ostatnią kropkę.

             Mega_Element_Rundy_Label.Caption := Mega_Element_Rundy_Label.Caption +
               #13 +
               Trim(  FormatFloat( '### ### ##0', mega_element__poziom_g )  ) + ' / ' +
               Sekundy_W_Czas_W_Minutach( mega_element__runda_czas__zakonczenia_g - mega_element__runda_czas__rozpoczecia_g ) +
               '.';
             //---// Wpisuje statystyki rund z mega elementem.

            end;
          //---//if Mega_Element_Kontener_GLDummyCube.Count <= 0 then


          Exit;

        end
      else//if mega_element__etap_g = mee_W_Grze then
      if mega_element__etap_g = mee_Runda_Zakonczona then
        begin

          if cele_list.Count > 0 then
            Exit; // Czeka aż wszystkie elementy (ułatwienia) znikną.

          mega_element__etap_g := mee_Brak;

          Mega_Element_Efekt_Wylicz();

        end;
      //---//if mega_element__etap_g = mee_Runda_Zakonczona then
      {$endregion 'Obsługa mega elementu.'}


      if mega_element__etap_g = mee_Brak then
        begin

          // Gdy etap nie dotyczy mega elementu sprawdza czas do dodania zwykłego celu.

          if Gra_GLCadencer.CurrentTime - cel__ostatnio_utworzony_czas_g < cel__czas_dodania_kolejnego_sekundy_g then
            Exit;


          cel__ostatnio_utworzony_czas_g := Gra_GLCadencer.CurrentTime;

        end;
      //---//if mega_element__etap_g = mee_Brak then

    end;
  //---//if rozmiar_poziomy_f <= 0 then


  Result := TCel.Create( Application, Gra_Elementy_GLDummyCube, rozmiar_poziomy_f, x_f, y_f, ekran_margines__boki_g, ekran_margines__istnienie__gora_dol_g, trafienie_mieczem_f );

  Cechy_Uzupelnij( Result );

end;//---//Funkcja Cele__Dodaj_Jeden().

//Funkcja Cele__Zwolnij_Jeden().
procedure TStrzelanka_Siekanka_Form.Cele__Zwolnij_Jeden( cel_f : TCel  );
begin

  // Usuwać tylko w jednym miejscu. !!!
  // Wywołanie tej funkcji w kliku miejscach może coś zepsuć.

  if   ( cele_list = nil )
    or (  not Assigned( cele_list )  )
    or ( cel_f = nil ) then
    Exit;


  if    ( not cel_f.usunac_cel )
    //and (  not  ( cel_f.modyfikator_rodzaj in [ mr_Cele_Mniej, mr_Cele_Szybciej, mr_Cele_Wiecej, mr_Cele_Wolniej ] )  )then
    and (  cel_f.modyfikator_rodzaj = mr_Brak ) then // Celów, które zawierają modyfikatory nie trzeba zestrzeliwać (jak gracz chce).
    inc( elementy_nie_zestrzelone_ilosc_g );

  cele_list.Remove( cel_f );
  FreeAndNil( cel_f );

end;//---//Funkcja Cele__Zwolnij_Jeden().

//Funkcja Cele__Zwolnij_Wszystkie().
procedure TStrzelanka_Siekanka_Form.Cele__Zwolnij_Wszystkie();
var
  i : integer;
begin

  if   ( cele_list = nil )
    or (  not Assigned( cele_list )  ) then
    Exit;

  for i := cele_list.Count - 1 downto 0 do
    begin

      TGLSceneObject(cele_list[ i ]).Free();
      cele_list.Delete( i );

    end;
  //---//for i := cele_list.Count - 1 downto 0 do

end;//---//Funkcja Cele__Zwolnij_Wszystkie().

//Funkcja Cele__Ruch().
procedure TStrzelanka_Siekanka_Form.Cele__Ruch( delta_czasu_f : double );
var
  i,
  zti
    : integer;
  ztr : real;
  zt_cel : TCel;
begin

  if   ( cele_list = nil )
    or (  not Assigned( cele_list )  ) then
    Exit;


  if mega_element__etap_g = mee_W_Grze then
    begin

      {$region 'Obsługa mega elementu.'}
      mega_element__runda_czas__zakonczenia_g := Gra_GLCadencer.CurrentTime;


      if mega_element__ruch_g = mer_Opadanie then
        begin

          if Mega_Element_Kontener_GLDummyCube.Position.Y >= 0 then
            Mega_Element_Kontener_GLDummyCube.Move( cel__ruch_szybkosc_g * delta_czasu_f )
          else//if Mega_Element_Kontener_GLDummyCube.Position.Y >= 0 then
            mega_element__ruch_g := mer_Uniki;

        end
      else//if mega_element__ruch_g = mer_Opadanie then
        begin

          // Uniki.
          if Gra_GLCadencer.CurrentTime - mega_element__unik_ostatni_czas_g >= mega_element__czas_uniku_kolejnego_sekundy_g then
            begin

              mega_element__unik_ostatni_czas_g := Gra_GLCadencer.CurrentTime;


              ztr := 50 + Random( 50 ); // Siła uniku.
              i := Random( 4 ) + 1;

              case i of
                1 : GetOrCreateInertia( Mega_Element_Kontener_GLDummyCube ).ApplyForce(  sila_wspolczynnik_staly_c, GLVectorGeometry.VectorMake( ztr, 0, 0 )  ); // Lewo.
                2 : GetOrCreateInertia( Mega_Element_Kontener_GLDummyCube ).ApplyForce(  sila_wspolczynnik_staly_c, GLVectorGeometry.VectorMake( -ztr, 0, 0 )  ); // Prawo.
                3 : GetOrCreateInertia( Mega_Element_Kontener_GLDummyCube ).ApplyForce(  sila_wspolczynnik_staly_c, GLVectorGeometry.VectorMake( 0, ztr, 0 )  ); // Góra.
                4 : GetOrCreateInertia( Mega_Element_Kontener_GLDummyCube ).ApplyForce(  sila_wspolczynnik_staly_c, GLVectorGeometry.VectorMake( 0, -ztr, 0 )  ); // Dół.
                end;
              //---//case i of


              ztr := 5000 + Random( 1000 ); // Siła uniku.
              i := Random( 6 ) + 1;

              case i of
                1 : GetOrCreateInertia( Mega_Element_Kontener_GLDummyCube ).ApplyTorque( sila_wspolczynnik_staly_c, 0, ztr, 0 ); // Lewo.
                2 : GetOrCreateInertia( Mega_Element_Kontener_GLDummyCube ).ApplyTorque( sila_wspolczynnik_staly_c, 0, -ztr, 0 ); // Prawo.
                3 : GetOrCreateInertia( Mega_Element_Kontener_GLDummyCube ).ApplyTorque( sila_wspolczynnik_staly_c, 0, 0, ztr ); // Przód w dół.
                4 : GetOrCreateInertia( Mega_Element_Kontener_GLDummyCube ).ApplyTorque( sila_wspolczynnik_staly_c, 0, 0, -ztr ); // Przód w górę.
                5 : GetOrCreateInertia( Mega_Element_Kontener_GLDummyCube ).ApplyTorque( sila_wspolczynnik_staly_c, ztr, 0, 0 ); // Beczka (góra w) prawo.
                6 : GetOrCreateInertia( Mega_Element_Kontener_GLDummyCube ).ApplyTorque( sila_wspolczynnik_staly_c, -ztr, 0, 0 ); // Beczka (góra w) lewo.
                end;
              //---//case i of

            end;
          //---//if Gra_GLCadencer.CurrentTime - mega_element__unik_ostatni_czas_g >= mega_element__czas_uniku_kolejnego_sekundy_g then
          //---// Uniki


          // Pilnuje aby element nie wylatywał poza boki ekranu.
          ztr := 0.25; // Siła powracania na ekran gry.

          if Abs( Mega_Element_Kontener_GLDummyCube.Position.X ) > ekran_margines__boki_g then
            begin

              if Mega_Element_Kontener_GLDummyCube.Position.X < 0 then
                GetOrCreateInertia( Mega_Element_Kontener_GLDummyCube ).ApplyForce(   delta_czasu_f, GLVectorGeometry.VectorMake(  Abs( -ekran_margines__boki_g + Mega_Element_Kontener_GLDummyCube.Position.X ) * ztr, 0, 0  )   )
              else//if Mega_Element_Kontener_GLDummyCube.Position.X < 0 then
                GetOrCreateInertia( Mega_Element_Kontener_GLDummyCube ).ApplyForce(   delta_czasu_f, GLVectorGeometry.VectorMake(  -Abs( ekran_margines__boki_g + Mega_Element_Kontener_GLDummyCube.Position.X ) * ztr, 0, 0  )   );

            end;
          //---//if Abs( Mega_Element_Kontener_GLDummyCube.Position.X ) > ekran_margines__boki_g then

          if Abs( Mega_Element_Kontener_GLDummyCube.Position.Y ) > ekran_margines__gora_dol_g then
            begin

              if Mega_Element_Kontener_GLDummyCube.Position.Y < 0 then
                GetOrCreateInertia( Mega_Element_Kontener_GLDummyCube ).ApplyForce(   delta_czasu_f, GLVectorGeometry.VectorMake(  0, Abs( -ekran_margines__gora_dol_g + Mega_Element_Kontener_GLDummyCube.Position.Y ) * ztr, 0  )   )
              else//if Mega_Element_Kontener_GLDummyCube.Position.Y < 0 then
                GetOrCreateInertia( Mega_Element_Kontener_GLDummyCube ).ApplyForce(   delta_czasu_f, GLVectorGeometry.VectorMake(  0, -Abs( ekran_margines__gora_dol_g + Mega_Element_Kontener_GLDummyCube.Position.Y ) * ztr, 0  )   );

            end;
          //---//if Abs( Mega_Element_Kontener_GLDummyCube.Position.Y ) > ekran_margines__gora_dol_g then
          //---// Pilnuje aby element nie wylatywał poza boki ekranu.

        end;
      //---//if mega_element__ruch_g = mer_Opadanie then
      {$endregion 'Obsługa mega elementu.'}

    end;
  //---//if mega_element__etap_g = mee_W_Grze then


  for i := cele_list.Count - 1 downto 0 do
    begin

      if not TCel(cele_list[ i ]).mega_element_skladnik then
        begin

          // Zwykły cel.

          TCel(cele_list[ i ]).Move( cel__ruch_szybkosc_g * delta_czasu_f );

          // Pilnuje aby elementy nie wylatywały poza boki ekranu.
          if Abs( TCel(cele_list[ i ]).Position.X ) > ekran_margines__boki_g then
            begin

              if TCel(cele_list[ i ]).Position.X < 0 then
                GetOrCreateInertia( TCel(cele_list[ i ]) ).ApplyForce(   delta_czasu_f, GLVectorGeometry.VectorMake(  Abs( -ekran_margines__boki_g + TCel(cele_list[ i ]).Position.X ) * 0.04, 0, 0  )   ) // 0.05
              else//if TCel(cele_list[ i ]).Position.X < 0 then
                GetOrCreateInertia( TCel(cele_list[ i ]) ).ApplyForce(   delta_czasu_f, GLVectorGeometry.VectorMake(  -Abs( ekran_margines__boki_g + TCel(cele_list[ i ]).Position.X ) * 0.04, 0, 0  )   );

            end;
          //---//if Abs( TCel(cele_list[ i ]).Position.X ) > ekran_margines__boki_g then
          //---// Pilnuje aby elementy nie wylatywały poza boki ekranu.

        end;
      //---//if not TCel(cele_list[ i ]).mega_element_skladnik then


      {$region 'Efekty ruchowe celów z modyfikatorami szybkości i częstotliwości.'}
      if    ( TCel(cele_list[ i ]).modyfikator_rodzaj in [ mr_Cele_Szybciej, mr_Cele_Wolniej ] )
        and (
                  (  Abs( GetOrCreateInertia( TCel(cele_list[ i ]).modyfikator_rodzaj_gl_dummy_cube ).TranslationSpeed.Z ) <= 0  )
               or (  TCel(cele_list[ i ]).modyfikator_rodzaj_gl_dummy_cube.DistanceTo( TCel(cele_list[ i ]) ) > 2  )
             ) then
        begin

          TCel(cele_list[ i ]).modyfikator_rodzaj_gl_dummy_cube.Position.Z := 0;
          GetOrCreateInertia( TCel(cele_list[ i ]).modyfikator_rodzaj_gl_dummy_cube ).TranslationSpeed.Z := 0;

          if TCel(cele_list[ i ]).modyfikator_rodzaj in [ mr_Cele_Szybciej ] then
            GetOrCreateInertia( TCel(cele_list[ i ]).modyfikator_rodzaj_gl_dummy_cube ).ApplyForce(  sila_wspolczynnik_staly_c, GLVectorGeometry.VectorMake( 0, 0, 100 )  )
          else//if TCel(cele_list[ i ]).modyfikator_rodzaj in [ mr_Cele_Szybciej ] then
            GetOrCreateInertia( TCel(cele_list[ i ]).modyfikator_rodzaj_gl_dummy_cube ).ApplyForce(  sila_wspolczynnik_staly_c, GLVectorGeometry.VectorMake( 0, 0, -100 )  );

        end
      else//if    ( TCel(cele_list[ i ]).modyfikator_rodzaj in [ mr_Cele_Szybciej, mr_Cele_Wolniej ] ) (...)
        begin

          if    ( TCel(cele_list[ i ]).modyfikator_rodzaj in [ mr_Cele_Czesciej ] )
            and (  Abs( GetOrCreateInertia( TCel(cele_list[ i ]).modyfikator_rodzaj_gl_dummy_cube ).RollSpeed ) <= 200  ) then
            begin

              //TCel(cele_list[ i ]).modyfikator_rodzaj_gl_dummy_cube.RollAngle := 0;

              GetOrCreateInertia( TCel(cele_list[ i ]).modyfikator_rodzaj_gl_dummy_cube ).ApplyTorque( sila_wspolczynnik_staly_c, 0, 50000, 0 );

            end
          else//if    ( TCel(cele_list[ i ]).modyfikator_rodzaj in [ mr_Cele_Czesciej, mr_Cele_Rzadziej ] ) ] ) (...)
          if TCel(cele_list[ i ]).modyfikator_rodzaj in [ mr_Cele_Rzadziej ] then
            TCel(cele_list[ i ]).modyfikator_rodzaj_gl_dummy_cube.Roll( delta_czasu_f * 50 );

        end;
      //---//if    ( TCel(cele_list[ i ]).modyfikator_rodzaj in [ mr_Cele_Czesciej, mr_Cele_Rzadziej ] ) ] ) (...)
      {$endregion 'Efekty ruchowe celów z modyfikatorami szybkości i częstotliwości.'}


      if    ( pelny_ekran__ilosc_zmian_g > 0 )
        and ( TCel(cele_list[ i ]).modyfikator_rodzaj_gl_scene_object is TGLArrowArc ) then
        begin

          // Przywraca widoczność obiektu gdy obiekt sam sobie znika.

          TGLArrowArc(TCel(cele_list[ i ]).modyfikator_rodzaj_gl_scene_object).StartAngle := TGLArrowArc(TCel(cele_list[ i ]).modyfikator_rodzaj_gl_scene_object).StartAngle + 1;
          TGLArrowArc(TCel(cele_list[ i ]).modyfikator_rodzaj_gl_scene_object).StartAngle := TGLArrowArc(TCel(cele_list[ i ]).modyfikator_rodzaj_gl_scene_object).StartAngle - 1;

        end;
      //---//if    ( pelny_ekran__ilosc_zmian_g > 0 ) (...)


      if   (
                 ( TCel(cele_list[ i ]).usunac_cel )
             and (
                      ( TCel(cele_list[ i ]).rozmiar_poziomy <= 0 )
                   or ( TCel(cele_list[ i ]).modyfikator_rodzaj in [ mr_Cele_Czesciej, mr_Cele_Rzadziej, mr_Cele_Szybciej, mr_Cele_Wolniej ] )
                 )
           )
        or (
                (
                      ( not TCel(cele_list[ i ]).mega_element_skladnik ) // Zwykły cel.
                  and ( TCel(cele_list[ i ]).AbsolutePosition.Y < -ekran_margines__istnienie__gora_dol_g - 4 )
                )
             or (
                      ( TCel(cele_list[ i ]).mega_element_skladnik ) // Mega element.
                  and ( TCel(cele_list[ i ]).AbsolutePosition.Y < -ekran_margines__istnienie__gora_dol_g * 40 )
                )
           )
        or (
                (
                      ( not TCel(cele_list[ i ]).mega_element_skladnik ) // Zwykły cel.
                  and ( Gra_GLCadencer.CurrentTime - TCel(cele_list[ i ]).utworzenie_czas > cel__czas_trwania_sekundy_g )
                )
             or (
                      ( TCel(cele_list[ i ]).mega_element_skladnik ) // Mega element.
                  and ( Gra_GLCadencer.CurrentTime - TCel(cele_list[ i ]).utworzenie_czas > mega_element__czas_trwania_sekundy_g )
                )
           )
        or ( TCel(cele_list[ i ]).DistanceTo( Gra_GLCamera ) > cel__dystans_trwania_g ) then
        begin

          if TCel(cele_list[ i ]).usunac_cel then
            begin

              Dzwieki__Rodzaj__Dodaj_Jeden( TCel(cele_list[ i ]).Position.X, TCel(cele_list[ i ]).Position.Y, dr_Pa );

              if TCel(cele_list[ i ]).modyfikator_rodzaj <> mr_Brak then
                Dzwieki__Rodzaj__Dodaj_Jeden( TCel(cele_list[ i ]).Position.X, TCel(cele_list[ i ]).Position.Y, dr_Modyfikator );

            end;
          //---//if TCel(cele_list[ i ]).usunac_cel then


          Cele__Zwolnij_Jeden( TCel(cele_list[ i ]) ); // W tym wypadku zawsze zwalnia.

        end
      else//if   ( (...)
      if    ( TCel(cele_list[ i ]).usunac_cel )
        and ( TCel(cele_list[ i ]).rozmiar_poziomy > 0 ) then
        begin

          TCel(cele_list[ i ]).usunac_cel := false;

          //TCel(cele_list[ i ]).modyfikator_rodzaj := mr_Brak;
          TCel(cele_list[ i ]).Effects.Clear();

          TCel(cele_list[ i ]).Skala_Ustaw();

          //if not TCel(cele_list[ i ]).trafienie_mieczem then
            TCel(cele_list[ i ]).TurnAngle := Random( 91 ) - 45; // Modyfikuje kierunek lotu celu.

          zt_cel := Cele__Dodaj_Jeden( TCel(cele_list[ i ]).rozmiar_poziomy, TCel(cele_list[ i ]).Position.X, TCel(cele_list[ i ]).Position.Y, TCel(cele_list[ i ]).trafienie_mieczem );

          // Współczynnik siły działającej na cele.
          if karabin_maszynowy__aktywnosc_g then
            ztr := 1.5
          else//if karabin_maszynowy__aktywnosc_g then
            ztr := 1;

          if not TCel(cele_list[ i ]).trafienie_mieczem then
            GetOrCreateInertia( TCel(cele_list[ i ]) ).ApplyForce(   delta_czasu_f, GLVectorGeometry.VectorMake(   ztr * (  400 - Random( 800 )  ), 0, ztr * Random( 25 )  )   ) // Poziom (lewo +), w głąb ekranu (w głąb +), pion (dół +).
          else//if not TCel(cele_list[ i ]).trafienie_mieczem then
            begin

              if TCel(cele_list[ i ]).rozmiar_poziomy > 0 then
                zti := TCel(cele_list[ i ]).rozmiar_poziomy
              else//if TCel(cele_list[ i ]).rozmiar_poziomy > 0 then
                zti := 1;

              GetOrCreateInertia( TCel(cele_list[ i ]) ).ApplyForce(   delta_czasu_f, GLVectorGeometry.VectorScale(  GLVectorGeometry.VectorMake( TCel(cele_list[ i ]).miecz_predkosc_affine_vektor ), 50 / zti  )   ); // Poziom (lewo +), w głąb ekranu (w głąb +), pion (dół +).

            end;
          //---//if not TCel(cele_list[ i ]).trafienie_mieczem then

          GetOrCreateInertia( TCel(cele_list[ i ]).element_widoczny_gl_scene_object ).ApplyTorque(  delta_czasu_f, ztr * (  120000 - Random( 60000 )  ), ztr * (  120000 - Random( 60000 )  ), ztr * (  120000 - Random( 60000 )  )  );


          if zt_cel <> nil then
            begin

              if not TCel(cele_list[ i ]).trafienie_mieczem then
                GetOrCreateInertia( zt_cel ).ApplyForce(   delta_czasu_f, GLVectorGeometry.VectorMake(   ztr * (  400 - Random( 800 )  ), 0, ztr * Random( 25 )  )   ) // Poziom (lewo +), w głąb ekranu (w głąb +), pion (dół +).
              else//if not TCel(cele_list[ i ]).trafienie_mieczem then
                begin

                  if TCel(zt_cel).rozmiar_poziomy > 0 then
                    zti := TCel(zt_cel).rozmiar_poziomy
                  else//if TCel(zt_cel).rozmiar_poziomy > 0 then
                    zti := 1;

                  GetOrCreateInertia( zt_cel ).ApplyForce(   delta_czasu_f, GLVectorGeometry.VectorScale(  GLVectorGeometry.VectorMake( TCel(cele_list[ i ]).miecz_predkosc_affine_vektor ), 50 / zti  )   ); // Poziom (lewo +), w głąb ekranu (w głąb +), pion (dół +).

                end;
              //---//if not TCel(cele_list[ i ]).trafienie_mieczem then

              GetOrCreateInertia( zt_cel.element_widoczny_gl_scene_object ).ApplyTorque(   delta_czasu_f, ztr * (  120000 - Random( 60000 )  ), ztr * (  120000 - Random( 60000 )  ), ztr * (  120000 - Random( 60000 )  )   );

            end;
          //---//if zt_cel <> nil then


          Dzwieki__Rodzaj__Dodaj_Jeden( TCel(cele_list[ i ]).Position.X, TCel(cele_list[ i ]).Position.Y, dr_Pa );


          if TCel(cele_list[ i ]).modyfikator_rodzaj <> mr_Brak then
            begin

              TCel(cele_list[ i ]).modyfikator_rodzaj := mr_Brak;
              Dzwieki__Rodzaj__Dodaj_Jeden( TCel(cele_list[ i ]).Position.X, TCel(cele_list[ i ]).Position.Y, dr_Modyfikator );

            end;
          //---//if TCel(cele_list[ i ]).modyfikator_rodzaj <> mr_Brak then

        end;
      //---//if    ( TCel(cele_list[ i ]).usunac_cel ) (...)

    end;
  //---//for i := cele_list.Count - 1 downto 0 do


  if pelny_ekran__ilosc_zmian_g > 0 then
    dec( pelny_ekran__ilosc_zmian_g );

end;//---//Funkcja Cele__Ruch().

//Funkcja Pociski__Dodaj_Jeden().
procedure TStrzelanka_Siekanka_Form.Pociski__Dodaj_Jeden( const kierunek_vektor_f : TAffineVector );
var
  ztr : real;
  zts : string;
  zt_pocisk : TPocisk;
begin

  if   ( pociski_list = nil )
    or (  not Assigned( pociski_list )  ) then
    Exit;


  // Współczynnik czasu przeładowania pocisku.
  if karabin_maszynowy__aktywnosc_g then
    ztr := 0.5
  else//if karabin_maszynowy__aktywnosc_g then
    ztr := 1;


  if   ( magazynek__pociski_ilosc_g <= 0 )
    or ( magazynek__przeladowywanie_w_trakcie )
    or ( Gra_GLCadencer.CurrentTime - pocisk__ostatnio_utworzony_czas_g < pocisk__przeladowanie_trwanie_g * ztr ) then
    Exit;


  if magazynek__pociski_ilosc_g > 0 then
    dec( magazynek__pociski_ilosc_g );

  if magazynek__pociski_ilosc_g <= 0 then
    begin

      Przeladuj_GLHUDText.Text := 'Przeładuj (reload)!';
      Przeladuj_GLHUDSprite.Width := Length( Przeladuj_GLHUDText.Text ) * 20;
      Przeladuj_GLWindowsBitmapFont.EnsureString( Przeladuj_GLHUDText.Text ); // Bez tego nie ma polskich znaków.

      Przeladuj_Komunikat_Ustaw( true );
      Przeladuj_Dzwiek_Ustaw( dzwieki__prefiks__przeladuj_c );

    end;
  //---//if magazynek__pociski_ilosc_g <= 0 then


  Napis_Odswiez( true );


  pocisk__ostatnio_utworzony_czas_g := Gra_GLCadencer.CurrentTime;


  zt_pocisk := TPocisk.Create( Application );
  zt_pocisk.Parent := Gra_GLScene.Objects;
  zt_pocisk.karabin_maszynowy_pocisk := karabin_maszynowy__aktywnosc_g;
  zt_pocisk.utworzenie_czas := Gra_GLCadencer.CurrentTime;
  zt_pocisk.Position := Gra_GLCamera.Position;
  zt_pocisk.Direction.AsAffineVector := kierunek_vektor_f;
  zt_pocisk.Radius := 0.05;
  zt_pocisk.Position.Y := zt_pocisk.Position.Y - 4 * zt_pocisk.Radius; // Aby nie widać było jak fragmenty elementu przesłaniają kamerę


  if karabin_maszynowy__aktywnosc_g then
    begin

      zt_pocisk.Material.FrontProperties.Ambient.Color := clrNavy;
      zt_pocisk.Material.FrontProperties.Diffuse.Color := clrSkyBlue;
      zt_pocisk.Material.FrontProperties.Emission.Color := clrBlue;

    end
  else//if karabin_maszynowy__aktywnosc_g then
    begin

      zt_pocisk.Material.FrontProperties.Ambient.Color := clrMaroon;
      zt_pocisk.Material.FrontProperties.Diffuse.Color := clrCoral;
      zt_pocisk.Material.FrontProperties.Emission.Color := clrRed;

    end;
  //---//if karabin_maszynowy__aktywnosc_g then


  // Dynamiczne dodanie zdarzenia kolizji.
  with TGLBCollision.Create( zt_pocisk.Behaviours ) do
    begin

      GroupIndex := 0;
      BoundingMode := cbmSphere;
      Manager := Gra_GLCollisionManager;

    end;
  //---//with TGLBCollision.Create( Pocisk_Magiczny_GLTorus.Behaviours ) do


  if not VectorEquals( Strzelanka_Siekanka_Form.Pocisk_GLFireFXManager.OuterColor.Color, zt_pocisk.Material.FrontProperties.Emission.Color ) then // uses GLVectorGeometry.
    Strzelanka_Siekanka_Form.Pocisk_GLFireFXManager.OuterColor.Color := zt_pocisk.Material.FrontProperties.Emission.Color;

  TGLBFireFX(zt_pocisk.AddNewEffect( TGLBFireFX )).Manager := Strzelanka_Siekanka_Form.Pocisk_GLFireFXManager;



  if karabin_maszynowy__aktywnosc_g then
    zts := dzwieki__prefiks__pociski__karabin_maszynowy_c
  else//if karabin_maszynowy__aktywnosc_g then
    zts := dzwieki__prefiks__pociski_c;

  if    ( ActiveSoundManager() <> nil )
    and ( Gra_GLSoundLibrary.Samples.GetByName( zts ) <> nil ) then
    with TGLBSoundEmitter.Create( zt_pocisk.Behaviours ) do
      begin

        Source.SoundLibrary := Gra_GLSoundLibrary;
        Source.SoundName := zts;
        Source.NbLoops := 2; // Wartość większa od 1 zapętla odtwarzanie w nieskończoność.
        Playing := true;

      end;
    //---//with TGLBSoundEmitter.Create( zt_pocisk.Behaviours ) do



  pociski_list.Add( zt_pocisk );

  inc( strzaly_ilosc_g );

end;//---//Funkcja Pociski__Dodaj_Jeden().

//Funkcja Pociski__Zwolnij_Jeden().
procedure TStrzelanka_Siekanka_Form.Pociski__Zwolnij_Jeden( pocisk_f : TPocisk  );
begin

  // Usuwać tylko w jednym miejscu. !!!
  // Wywołanie tej funkcji w kliku miejscach może coś zepsuć.

  if   ( pociski_list = nil )
    or (  not Assigned( pociski_list )  )
    or ( pocisk_f = nil ) then
    Exit;

  pociski_list.Remove( pocisk_f );
  FreeAndNil( pocisk_f );

end;//---//Funkcja Pociski__Zwolnij_Jeden().

//Funkcja Pociski__Zwolnij_Wszystkie().
procedure TStrzelanka_Siekanka_Form.Pociski__Zwolnij_Wszystkie();
var
  i : integer;
begin

  if   ( pociski_list = nil )
    or (  not Assigned( pociski_list )  ) then
    Exit;

  for i := pociski_list.Count - 1 downto 0 do
    begin

      TPocisk(pociski_list[ i ]).Free();
      pociski_list.Delete( i );

    end;
  //---//for i := pociski_list.Count - 1 downto 0 do

end;//---//Funkcja Pociski__Zwolnij_Wszystkie().

//Funkcja Pociski__Ruch().
procedure TStrzelanka_Siekanka_Form.Pociski__Ruch( delta_czasu_f : double );
var
  i : integer;
  zti : smallint;
begin

  if   ( pociski_list = nil )
    or (  not Assigned( pociski_list )  ) then
    Exit;


  for i := pociski_list.Count - 1 downto 0 do
    begin

      if TPocisk(pociski_list[ i ]).karabin_maszynowy_pocisk then
        zti := 2
      else//if TPocisk(pociski_list[ i ]).karabin_maszynowy_pocisk then
        zti := 1;

      TPocisk(pociski_list[ i ]).Move( pocisk__ruch_szybkosc_g * zti * delta_czasu_f );

      if   ( TPocisk(pociski_list[ i ]).usunsc_pocisk )
        or ( Gra_GLCadencer.CurrentTime - TPocisk(pociski_list[ i ]).utworzenie_czas > pocisk__czas_trwania_sekundy_g )
        or ( TPocisk(pociski_list[ i ]).DistanceTo( Gra_GLCamera ) > pocisk__dystans_trwania_g ) then
        Pociski__Zwolnij_Jeden( TPocisk(pociski_list[ i ]) );

    end;
  //---//for i := pociski_list.Count - 1 downto 0 do

end;//---//Funkcja Pociski__Ruch().

//Funkcja Miecz__Kolizji_Elementy__Dodaj().
procedure TStrzelanka_Siekanka_Form.Miecz__Kolizji_Elementy__Dodaj();
const
  promien_c_l : real = 0.05;
var
  zti : integer;
  ztr : real;
  zt_gl_sphere : TGLSphere;
begin

  // Nie wykrywa kolizji celów z elementami wizualnymi miecza więc tutaj są dodawane obiekty dla wykrywające te kolizje.

  zti := 0;
  ztr := -3;

  while ztr < 3 do
    begin

      inc( zti );

      zt_gl_sphere := TGLSphere.Create( Application );
      zt_gl_sphere.Parent := Miecz_Kontener_GLDummyCube;
      zt_gl_sphere.Name := miecz_kolizje_elementy_nazwa_prefiks_c + Trim(  FormatFloat( '000000', zti )  );
      zt_gl_sphere.Radius := promien_c_l;
      zt_gl_sphere.Visible := false;
      zt_gl_sphere.Position.X := ztr;
      zt_gl_sphere.Position.Z := 0.15 - zt_gl_sphere.Radius;

      ztr := ztr + zt_gl_sphere.Radius * 2 + zt_gl_sphere.Radius * 0.01;

      // Dynamiczne dodanie zdarzenia kolizji.
      with TGLBCollision.Create( zt_gl_sphere.Behaviours ) do
        begin

          GroupIndex := 0;
          BoundingMode := cbmSphere;
          Manager := Gra_GLCollisionManager;

        end;
      //---//with TGLBCollision.Create( Pocisk_Magiczny_GLTorus.Behaviours ) do

      //zt_gl_sphere.Material.FrontProperties.Ambient.Color := clrNavy;
      //zt_gl_sphere.Material.FrontProperties.Diffuse.Color := clrSkyBlue;
      //zt_gl_sphere.Material.FrontProperties.Emission.Color := clrBlue;

    end;
  //---//while ztr < 3 do


  // Czubek czubek.
  inc( zti );

  zt_gl_sphere := TGLSphere.Create( Application );
  zt_gl_sphere.Parent := Miecz_Kontener_GLDummyCube;
  zt_gl_sphere.Name := miecz_kolizje_elementy_nazwa_prefiks_c + Trim(  FormatFloat( '000000', zti )  );
  zt_gl_sphere.Radius := promien_c_l;
  zt_gl_sphere.Visible := false;
  zt_gl_sphere.Position.X := -3.22;
  zt_gl_sphere.Position.Z := -0.067;

  // Dynamiczne dodanie zdarzenia kolizji.
  with TGLBCollision.Create( zt_gl_sphere.Behaviours ) do
    begin

      GroupIndex := 0;
      BoundingMode := cbmSphere;
      Manager := Gra_GLCollisionManager;

    end;
  //---//with TGLBCollision.Create( Pocisk_Magiczny_GLTorus.Behaviours ) do

  //zt_gl_sphere.Material.FrontProperties.Ambient.Color := clrNavy;
  //zt_gl_sphere.Material.FrontProperties.Diffuse.Color := clrSkyBlue;
  //zt_gl_sphere.Material.FrontProperties.Emission.Color := clrBlue;


  // Czubek środek.
  inc( zti );

  zt_gl_sphere := TGLSphere.Create( Application );
  zt_gl_sphere.Parent := Miecz_Kontener_GLDummyCube;
  zt_gl_sphere.Name := miecz_kolizje_elementy_nazwa_prefiks_c + Trim(  FormatFloat( '000000', zti )  );
  zt_gl_sphere.Radius := promien_c_l;
  zt_gl_sphere.Visible := false;
  zt_gl_sphere.Position.X := -3.125;
  zt_gl_sphere.Position.Z := 0.0165;

  // Dynamiczne dodanie zdarzenia kolizji.
  with TGLBCollision.Create( zt_gl_sphere.Behaviours ) do
    begin

      GroupIndex := 0;
      BoundingMode := cbmSphere;
      Manager := Gra_GLCollisionManager;

    end;
  //---//with TGLBCollision.Create( Pocisk_Magiczny_GLTorus.Behaviours ) do

  //zt_gl_sphere.Material.FrontProperties.Ambient.Color := clrNavy;
  //zt_gl_sphere.Material.FrontProperties.Diffuse.Color := clrSkyBlue;
  //zt_gl_sphere.Material.FrontProperties.Emission.Color := clrBlue;

end;//---//Funkcja Miecz__Kolizji_Elementy__Dodaj().

//Funkcja Miecz__Kolizji_Elementy__Zwolnij_Wszystkie().
procedure TStrzelanka_Siekanka_Form.Miecz__Kolizji_Elementy__Zwolnij_Wszystkie();
var
  i : integer;
begin

  for i := 0 to Miecz_Kontener_GLDummyCube.Count - 1 do
    if    ( Miecz_Kontener_GLDummyCube.Children[ i ] is TGLSphere )
      and (  Pos( miecz_kolizje_elementy_nazwa_prefiks_c, Miecz_Kontener_GLDummyCube.Children[ i ].Name ) > 0  ) then
      Miecz_Ostrze_GLCylinder.Children[ i ].Free();

end;//---//Funkcja Miecz__Kolizji_Elementy_Zwolnij__Wszystkie().

//Funkcja Miecz_Ruch().
procedure TStrzelanka_Siekanka_Form.Miecz_Ruch( delta_czasu_f : double );
var
  zti : integer;
  mysz_pozycja : TPoint;
  zt_affine_vektor : TAffineVector;
  zt_vektor : TVector;
  miecz_predkosc_l : real;
  miecz_predkosc_affine_vektor_l : TAffineVector;
begin

  {$region 'Animacja dobywania i chowania miecza.'}
  if miecz_dobycie_etap_g = mde_Chowa_Sie then
    begin

      if miecz_chowanie_sie_etap = mche_Efekty_Neutralizuj then
        begin

          zti := Miecz_Kontener_GLDummyCube.Behaviours.IndexOfClass( TGLBSoundEmitter ); // -1 - brak, >= 0 zachowania.

          if    ( zti >= 0 )
            and ( ActiveSoundManager() <> nil )then
            TGLBSoundEmitter(Miecz_Kontener_GLDummyCube.Behaviours.Items[ zti ]).Playing := false;

          GetOrCreateInertia( Miecz_Kontener_GLDummyCube ).TranslationSpeed.SetToZero();


          miecz_chowanie_sie_etap := mche_Obrot_Do_Pozycji__Ostrze_W_Gore;

        end
      else//if miecz_chowanie_sie_etap = mche_Efekty_Neutralizuj then
      if miecz_chowanie_sie_etap = mche_Obrot_Do_Pozycji__Ostrze_W_Gore then
        begin

          if Abs( Miecz_Kontener_GLDummyCube.PitchAngle - 90 ) > 2 then
            begin

              // Obraca ostrzem do góry.

              if    ( Miecz_Kontener_GLDummyCube.PitchAngle <= 90 )
                and ( Miecz_Kontener_GLDummyCube.PitchAngle >= -90 )then
                Miecz_Kontener_GLDummyCube.PitchAngle := Miecz_Kontener_GLDummyCube.PitchAngle + 1
              else//if    ( Miecz_Kontener_GLDummyCube.PitchAngle <= 90 ) (...)
                Miecz_Kontener_GLDummyCube.PitchAngle := Miecz_Kontener_GLDummyCube.PitchAngle - 1;

            end
          else//if Abs( Miecz_Kontener_GLDummyCube.PitchAngle - 90 ) > 2 then
            begin

              Miecz_Kontener_GLDummyCube.PitchAngle := 90;
              miecz_chowanie_sie_etap := mche_Ruch_Do_Pozycji;

            end;
          //---//if Abs( Miecz_Kontener_GLDummyCube.PitchAngle - 90 ) > 2 then

        end
      else//if miecz_chowanie_sie_etap = mche_Obrot_Do_Pozycji__Ostrze_W_Gore then
      if miecz_chowanie_sie_etap = mche_Ruch_Do_Pozycji then
        begin

          if Abs( Miecz_Kontener_GLDummyCube.Position.Y + 1 ) > 0.01 then
            begin

              if Miecz_Kontener_GLDummyCube.Position.Y > -1 then
                Miecz_Kontener_GLDummyCube.Move( -delta_czasu_f * 2 )
              else
              if Miecz_Kontener_GLDummyCube.Position.Y < -1 then
                Miecz_Kontener_GLDummyCube.Move( delta_czasu_f * 2 );

            end
          else//if Abs( Miecz_Kontener_GLDummyCube.Position.Y + 1 ) > 0.01 then
            Miecz_Kontener_GLDummyCube.Position.Y := -1;


          if Abs( Miecz_Kontener_GLDummyCube.Position.X - 1 ) > 0.01 then
            begin

              if Miecz_Kontener_GLDummyCube.Position.X > 1 then
                Miecz_Kontener_GLDummyCube.Lift( delta_czasu_f * 2 )
              else
              if Miecz_Kontener_GLDummyCube.Position.X < 1 then
                Miecz_Kontener_GLDummyCube.Lift( -delta_czasu_f * 2 );

            end
          else//if Abs( Miecz_Kontener_GLDummyCube.Position.X - 1 ) > 0.01 then
            Miecz_Kontener_GLDummyCube.Position.X := 1;


          if    ( Miecz_Kontener_GLDummyCube.Position.Y = -1 )
            and ( Miecz_Kontener_GLDummyCube.Position.X = 1 ) then
            miecz_chowanie_sie_etap := mche_Obrot_Do_Pozycji__Rekojesc_W_Przod;

        end
      else//if miecz_chowanie_sie_etap = mche_Ruch_Do_Pozycji then
      if miecz_chowanie_sie_etap = mche_Obrot_Do_Pozycji__Rekojesc_W_Przod then
        begin

          if Abs( Miecz_Kontener_GLDummyCube.RollAngle - 180 ) > 2 then
            begin

              // Obraca rękojeścią w przód.

              Miecz_Kontener_GLDummyCube.RollAngle := Miecz_Kontener_GLDummyCube.RollAngle + 1;

            end
          else//if Abs( Miecz_Kontener_GLDummyCube.RollAngle - 180 ) > 2 then
            begin

              Miecz_Kontener_GLDummyCube.RollAngle := 180;
              miecz_chowanie_sie_etap := mche_Gotowy;

            end;
          //---//if Abs( Miecz_Kontener_GLDummyCube.RollAngle - 180 ) > 2 then

        end
      else//if miecz_chowanie_sie_etap = mche_Obrot_Do_Pozycji__Rekojesc_W_Przod then
      if miecz_chowanie_sie_etap = mche_Gotowy then
        begin

          if Miecz_Kontener_GLDummyCube.Position.Z > -5 then
            Miecz_Kontener_GLDummyCube.Slide( delta_czasu_f * 4 )
          else//if Miecz_Kontener_GLDummyCube.Position.Z > -5 then
            begin

              miecz_chowanie_sie_etap := mche_Brak;
              miecz_dobycie_etap_g := mde_Schowany;

            end;
          //---//if Miecz_Kontener_GLDummyCube.Position.Z > -5 then

        end;
      //---//if miecz_chowanie_sie_etap = mche_Gotowy then

    end
  else//if miecz_dobycie_etap_g = mde_Chowa_Sie then
  if miecz_dobycie_etap_g = mde_Dobywa_Sie then
    begin

      if miecz_chowanie_sie_etap = mche_Ruch_Do_Pozycji then
        begin

          if Miecz_Kontener_GLDummyCube.Position.Z > 4 then
            begin

              if Miecz_Kontener_GLDummyCube.Position.Y < 0 then
                Miecz_Kontener_GLDummyCube.Move( delta_czasu_f * 1 )
              else//if Miecz_Kontener_GLDummyCube.Position.Y < 0 then
                Miecz_Kontener_GLDummyCube.Position.Y := 0;

            end;
          //---//if Miecz_Kontener_GLDummyCube.Position.Z > 1 then


          if Miecz_Kontener_GLDummyCube.Position.Z < 10 then
            Miecz_Kontener_GLDummyCube.Slide( -delta_czasu_f * 4 )
          else//if Miecz_Kontener_GLDummyCube.Position.Z < 10 then
            Miecz_Kontener_GLDummyCube.Position.Z := 10;

          if    ( Miecz_Kontener_GLDummyCube.Position.Y = 0 )
            and ( Miecz_Kontener_GLDummyCube.Position.Z = 10 ) then
            miecz_chowanie_sie_etap := mche_Obrot_Do_Pozycji__Rekojesc_W_Przod;

        end
      else//if miecz_dobycie_etap_g = mche_Ruch_Do_Pozycji then
      if miecz_chowanie_sie_etap = mche_Obrot_Do_Pozycji__Rekojesc_W_Przod then
        begin

          // Wcześniej nie można obracać, gdyż przesunięcia się odkształcą.

          if Miecz_Kontener_GLDummyCube.TurnAngle <> -90 then
            begin

              // Obraca rękojeścią w tył.

              if Abs( Miecz_Kontener_GLDummyCube.TurnAngle + 90 ) > 2 then
                Miecz_Kontener_GLDummyCube.TurnAngle := Miecz_Kontener_GLDummyCube.TurnAngle + 1
              else//if Abs( Miecz_Kontener_GLDummyCube.TurnAngle - 180 ) > 2 then
                Miecz_Kontener_GLDummyCube.TurnAngle := -90;

            end
          else//if Miecz_Kontener_GLDummyCube.TurnAngle <> -90 then
            miecz_chowanie_sie_etap := mche_Gotowy;

        end
      else//if miecz_chowanie_sie_etap = mche_Obrot_Do_Pozycji__Rekojesc_W_Przod then
        begin

          if miecz_chowanie_sie_etap = mche_Gotowy then
            begin

              miecz_chowanie_sie_etap := mche_Brak;

              Miecz_Kontener_GLDummyCube.ResetRotations();

              Miecz_Kontener_GLDummyCube.TurnAngle := 90;

            end;
          //---//if miecz_chowanie_sie_etap = mche_Gotowy then


          miecz_dobycie_etap_g := mde_Dobyty;

        end;
      //---//if miecz_dobycie_etap_g = mche_Ruch_Do_Pozycji then

    end;
  //---//if miecz_dobycie_etap_g = mde_Dobywa_Sie then
  {$endregion 'Animacja dobywania i chowania miecza.'}


  if miecz_dobycie_etap_g <> mde_Dobyty then
    Exit;


  mysz_pozycja := ScreenToClient( Mouse.CursorPos );

  if Gra_GLSceneViewer.Buffer.ScreenVectorIntersectWithPlaneXY(  GLVectorGeometry.VectorMake( mysz_pozycja.X, mysz_pozycja.Y, 0 ), 10, zt_vektor  ) then
    begin

      GetOrCreateInertia( Miecz_Kontener_GLDummyCube ).ApplyForce
        (
          sila_wspolczynnik_staly_c,
          GLVectorGeometry.VectorMake
            (
                zt_vektor.X - Miecz_Kontener_GLDummyCube.Position.X
              , -zt_vektor.Y - Miecz_Kontener_GLDummyCube.Position.Y
              , 0
            )
        );


      zt_affine_vektor := GetOrCreateInertia( Miecz_Kontener_GLDummyCube ).TranslationSpeed.AsAffineVector;

      Miecz_Kontener_GLDummyCube.PitchAngle :=
        RadToDeg( // uses Math.
            AngleBetweenVectors( // uses GLVectorGeometry.
               GLVectorGeometry.VectorMake( zt_affine_vektor.X, zt_affine_vektor.Y, 0 ),
               GLVectorGeometry.VectorMake( 1, 0, 0 ),
               GLVectorGeometry.VectorMake( 0, 0, 0 )
             )
          );

      if zt_affine_vektor.Y < 0 then
        Miecz_Kontener_GLDummyCube.PitchAngle := -Miecz_Kontener_GLDummyCube.PitchAngle;


      // Ustawianie kierunku w taki sposób czasami obraca rękojeścią w głąb ekranu.
      //Miecz_Kontener_GLDummyCube.Direction.AsAffineVector := GLVectorGeometry.VectorNormalize(  GetOrCreateInertia( Miecz_Kontener_GLDummyCube ).TranslationSpeed.AsAffineVector  );
      //Miecz_Kontener_GLDummyCube.Direction.X := GetOrCreateInertia( Miecz_Kontener_GLDummyCube ).TranslationSpeed.X;
      //Miecz_Kontener_GLDummyCube.Direction.Y := GetOrCreateInertia( Miecz_Kontener_GLDummyCube ).TranslationSpeed.Y;
      //Miecz_Kontener_GLDummyCube.Direction.Z := 0;

    end;
  //---//if Gra_GLSceneViewer.Buffer.ScreenVectorIntersectWithPlaneXY(  GLVectorGeometry.VectorMake( mysz_pozycja.X, mysz_pozycja.Y, 0 ), 10, zt_vektor  ) then


  zti := Miecz_Kontener_GLDummyCube.Behaviours.IndexOfClass( TGLBSoundEmitter ); // -1 - brak, >= 0 zachowania.

  if zti >= 0 then
    begin

      miecz_predkosc_affine_vektor_l := GetOrCreateInertia( Miecz_Kontener_GLDummyCube ).TranslationSpeed.AsAffineVector;

      miecz_predkosc_l := Sqr( miecz_predkosc_affine_vektor_l.X ) + Sqr( miecz_predkosc_affine_vektor_l.Y );

      if miecz_predkosc_l > 0 then
        miecz_predkosc_l := Sqrt( miecz_predkosc_l )
      else//if miecz_predkosc_l > 0 then
        miecz_predkosc_l := 0;

      if ActiveSoundManager() <> nil then
        TGLBSoundEmitter(Miecz_Kontener_GLDummyCube.Behaviours.Items[ zti ]).Playing := miecz_predkosc_l > 20;

    end;
  //---//if zti >= 0 then


  //if    ( zti >= 0 )
  //  and ( not TGLBSoundEmitter(Miecz_Kontener_GLDummyCube.Behaviours.Items[ zti ]).Playing ) then
  //  begin
  //
  //    miecz_predkosc_affine_vektor_l := GetOrCreateInertia( Miecz_Kontener_GLDummyCube ).TranslationSpeed.AsAffineVector;
  //
  //    miecz_predkosc_l := Sqr( miecz_predkosc_affine_vektor_l.X ) + Sqr( miecz_predkosc_affine_vektor_l.Y );
  //
  //    if    ( miecz_predkosc_l > 3 )
  //      and ( ActiveSoundManager() <> nil ) then
  //      TGLBSoundEmitter(Miecz_Kontener_GLDummyCube.Behaviours.Items[ zti ]).Playing := true;
  //
  //  end;
  ////---//if    ( zti >= 0 ) (...)

end;//---//Funkcja Miecz_Ruch().

//Funkcja Dzwieki__Rodzaj__Dodaj_Jeden().
procedure TStrzelanka_Siekanka_Form.Dzwieki__Rodzaj__Dodaj_Jeden( const x_f, y_f : real; const dzwiek_rodzaj_f : TDzwiek_Rodzaj );
var
  i,
  zti,
  dzwieki_ilosc_l
    : integer;
  dzwieki_prefiks_l : string;
  zt_gl_dummy_cube : TGLDummyCube;
begin

  if   ( dzwieki__rodzaj_list = nil )
    or (  not Assigned( dzwieki__rodzaj_list )  )
    or ( ActiveSoundManager() = nil ) then
    Exit;


  if dzwiek_rodzaj_f = dr_Modyfikator then
    begin

      if dzwieki__modyfikator_ilosc_g <= 0 then
        Exit;

      dzwieki_ilosc_l := dzwieki__modyfikator_ilosc_g;
      dzwieki_prefiks_l := dzwieki__prefiks__modyfikator_c;

    end
  else//if dzwiek_rodzaj_f = dr_Modyfikator then
  if dzwiek_rodzaj_f = dr_Pa then
    begin

      if dzwieki__pa_ilosc_g <= 0 then
        Exit;

      dzwieki_ilosc_l := dzwieki__pa_ilosc_g;
      dzwieki_prefiks_l := dzwieki__prefiks__pa_c;

    end
  else//if dzwiek_rodzaj_f = dr_Pa then
    Exit;


  zt_gl_dummy_cube := TGLDummyCube.Create( Application );
  zt_gl_dummy_cube.Parent := Gra_GLScene.Objects;
  zt_gl_dummy_cube.Position.X := x_f;
  zt_gl_dummy_cube.Position.Y := y_f;
  zt_gl_dummy_cube.Position.Z := 10;
  //zt_gl_dummy_cube.VisibleAtRunTime := true; //???

  dzwieki__rodzaj_list.Add( zt_gl_dummy_cube );


  zti := Random( dzwieki_ilosc_l ) + 1;

  if ActiveSoundManager() <> nil then
    with TGLBSoundEmitter.Create( zt_gl_dummy_cube.Behaviours ) do
      begin

        Source.SoundLibrary := Gra_GLSoundLibrary;
        Source.SoundName := dzwieki_prefiks_l + Trim(  FormatFloat( '00', zti )  );
        Playing := true;

      end;
    //---//with TGLBSoundEmitter.Create( zt_gl_dummy_cube.Behaviours ) do


  // Zwalnia dźwięki, które już zakończyły wybrzmiewanie.
  for i := dzwieki__rodzaj_list.Count - 1 downto 0 do
    begin

      zti := TGLDummyCube(dzwieki__rodzaj_list[ i ]).Behaviours.IndexOfClass( TGLBSoundEmitter ); // -1 - brak, >= 0 indeks zachowania.

      if    ( zti >= 0 )
        and ( not TGLBSoundEmitter(TGLDummyCube(dzwieki__rodzaj_list[ i ]).Behaviours.Items[ zti ]).Playing ) then
        begin

          TGLDummyCube(dzwieki__rodzaj_list[ i ]).Free();
          dzwieki__rodzaj_list.Delete( i );

        end;
      //---//if    ( zti >= 0 ) (...)

    end;
  //---//for i := dzwieki__rodzaj_list.Count - 1 downto 0 do
  //---// Zwalnia dźwięki, które już zakończyły wybrzmiewanie.

end;//---//Funkcja Dzwieki__Rodzaj__Dodaj_Jeden().

//Funkcja Dzwieki__Rodzaj__Zwolnij_Wszystkie().
procedure TStrzelanka_Siekanka_Form.Dzwieki__Rodzaj__Zwolnij_Wszystkie();
var
  i : integer;
begin

  if   ( dzwieki__rodzaj_list = nil )
    or (  not Assigned( dzwieki__rodzaj_list )  ) then
    Exit;

  for i := dzwieki__rodzaj_list.Count - 1 downto 0 do
    begin

      TGLDummyCube(dzwieki__rodzaj_list[ i ]).Free();
      dzwieki__rodzaj_list.Delete( i );

    end;
  //---//for i := dzwieki__rodzaj_list.Count - 1 downto 0 do

end;//---//Funkcja Dzwieki__Rodzaj__Zwolnij_Wszystkie().

//Funkcja Napis_Odswiez().
procedure TStrzelanka_Siekanka_Form.Napis_Odswiez( const oczekiwanie_pomin_f : boolean = false );
const
  odstep_c : string = ' ';
var
  i : smallint;
  ztr : real;
  zts : string;
begin

  if    ( not oczekiwanie_pomin_f )
    and ( Gra_GLCadencer.CurrentTime - Statystyki_GLHUDText.TagFloat < 0.3 ) then
    Exit;


  Statystyki_GLHUDText.Text := '';


  if not Gra_GLCadencer.Enabled then
    Statystyki_GLHUDText.Text := Statystyki_GLHUDText.Text +
      #13 + #10 +
      odstep_c + odstep_c + 'Strzelanka Siekanka z Eris Kallisti Dyskordia' +
      #13 + #10 +
      #13 + #10 +
      #13 + #10 +
      odstep_c + odstep_c + 'PAUZA' +
      #13 + #10 +
      #13 + #10 +
      #13 + #10 +
      odstep_c + 'Aby wyświetlić pomoc omieść kursor na co najmniej 3 sekundy w prawym górnym rogu w polu ze znakiem zapytania [?].' +
      #13 + #10 +
      odstep_c + '[To display help hold the cursor for at least 3 seconds at the right top corner in the area with the question sign [?].]' +
      #13 + #10 +
      #13 + #10;


  if strzaly_ilosc_g = 0 then
    ztr := 0
  else//if strzaly_ilosc_g = 0 then
    ztr := trafienia_ilosc_g * 100 / strzaly_ilosc_g;

  Statystyki_GLHUDText.Text := Statystyki_GLHUDText.Text +
    odstep_c + 'm, t/s: ' + Trim(  FormatFloat( '### ### ##0', trafienia_ilosc_miecz_g )  ) + ', ' + Trim(  FormatFloat( '### ### ##0', trafienia_ilosc_g )  ) +
    ' / ' + Trim(  FormatFloat( '### ### ##0', strzaly_ilosc_g )  ) +
    ' - ' + Trim(  FormatFloat( '### ### ##0.00', ztr )  ) + '%';


  if not Gra_GLCadencer.Enabled then
    Statystyki_GLHUDText.Text := Statystyki_GLHUDText.Text +
      ' [ilość trafień mieczem, ilość trafień / ilość strzałów - wskaźnik procentowy' +
      #13 + #10 +
      '          (number of hits with the sword, number of hits / number of shots - percentage indicator)]';


  if elementy_wszystkie_ilosc_g = 0 then
    ztr := 0
  else//if elementy_wszystkie_ilosc_g = 0 then
    ztr := elementy_nie_zestrzelone_ilosc_g * 100 / elementy_wszystkie_ilosc_g;

  Statystyki_GLHUDText.Text := Statystyki_GLHUDText.Text +
    #13 + #10 +
    odstep_c + 'x/w: ' + Trim(  FormatFloat( '### ### ##0', elementy_nie_zestrzelone_ilosc_g )  ) +
    ' / ' + Trim(  FormatFloat( '### ### ##0', elementy_wszystkie_ilosc_g )  ) +
    ' - ' + Trim(  FormatFloat( '### ### ##0.00', ztr )  ) + '%';

  if not Gra_GLCadencer.Enabled then
    Statystyki_GLHUDText.Text := Statystyki_GLHUDText.Text +
      ' [ilość elementów, które uciekły / ilość wszystkich elementów - wskaźnik procentowy' +
      #13 + #10 +
      '          (the number of elements that have escaped / number of all elements - percentage indicator)]';


  Statystyki_GLHUDText.Text := Statystyki_GLHUDText.Text +
    #13 + #10 +
    odstep_c + 'p: ' + Trim(  FormatFloat( '### ### ##0', magazynek__przeladowania_ilosc_g )  );

  if not Gra_GLCadencer.Enabled then
    Statystyki_GLHUDText.Text := Statystyki_GLHUDText.Text +
      ' [ilość przeładowań (number of reloads)]';


  Statystyki_GLHUDText.Text := Statystyki_GLHUDText.Text +
    #13 + #10 +
    odstep_c + 'km ';

  if karabin_maszynowy__aktywnosc_g then
    Statystyki_GLHUDText.Text := Statystyki_GLHUDText.Text +
      ' - ' + Trim(   FormatFloat(  '### ### ##0.00', karabin_maszynowy__trwanie_sekundy_g - ( Gra_GLCadencer.CurrentTime - karabin_maszynowy__utworzenie_czas_g )  )   ) + ' [s]'
  else//if karabin_maszynowy__aktywnosc_g then
    Statystyki_GLHUDText.Text := Statystyki_GLHUDText.Text +
      ' - x';

  if not Gra_GLCadencer.Enabled then
    Statystyki_GLHUDText.Text := Statystyki_GLHUDText.Text +
      ' [tryb karabinu maszynowego - czas do dezaktywacji (machine gun mode - time until deactivation)]';


  Statystyki_GLHUDText.Text := Statystyki_GLHUDText.Text +
    #13 + #10 +
    odstep_c + 'mm: ' + Trim(  FormatFloat( '### ### ##0', magazynek__mnoznik_g )  );

  if magazynek__mnoznik_g > 1 then
    Statystyki_GLHUDText.Text := Statystyki_GLHUDText.Text +
      ' - ' + Trim(   FormatFloat(  '### ### ##0.00', magazynek__mnoznik__trwanie_sekundy_g - ( Gra_GLCadencer.CurrentTime - magazynek__mnoznik__utworzenie_czas_g )  )   ) + ' [s]';

  if not Gra_GLCadencer.Enabled then
    Statystyki_GLHUDText.Text := Statystyki_GLHUDText.Text +
      ' [mnożnik magazynka - czas do zmniejszenia (magazine  multiplier - time to decrease)]';


  Statystyki_GLHUDText.Text := Statystyki_GLHUDText.Text +
    #13 + #10 +
    odstep_c + 'cc: ' + Trim(  FormatFloat( '### ### ##0.00', cel__czas_dodania_kolejnego_sekundy_g )  );

  if not Gra_GLCadencer.Enabled then
    Statystyki_GLHUDText.Text := Statystyki_GLHUDText.Text +
      ' [cele częstotliwość pojawiania się (targets spawn frequency)]';


  Statystyki_GLHUDText.Text := Statystyki_GLHUDText.Text +
    #13 + #10 +
    odstep_c + 'cs: ' + Trim(  FormatFloat( '### ### ##0.00', cel__ruch_szybkosc_g )  );

  if not Gra_GLCadencer.Enabled then
    Statystyki_GLHUDText.Text := Statystyki_GLHUDText.Text +
      ' [cele szybkość ruchu (targets speed of movement)]';


  if Mega_Element_CheckBox.Checked then
    begin

      Statystyki_GLHUDText.Text := Statystyki_GLHUDText.Text +
        #13 + #10 +
        odstep_c + 'mep: ' + Trim(  FormatFloat( '### ### ##0', mega_element__poziom_g )  );

      if not Gra_GLCadencer.Enabled then
        Statystyki_GLHUDText.Text := Statystyki_GLHUDText.Text +
          ' [poziom mega elementu (mega element level)]';


      Statystyki_GLHUDText.Text := Statystyki_GLHUDText.Text +
        #13 + #10 +
        odstep_c + 'mec: ' + Sekundy_W_Czas_W_Minutach( mega_element__runda_czas__zakonczenia_g - mega_element__runda_czas__rozpoczecia_g );

      if not Gra_GLCadencer.Enabled then
        Statystyki_GLHUDText.Text := Statystyki_GLHUDText.Text +
          ' [czas trwania rundy z mega elementem (duration of a round with the mega element)]';

    end;
  //---//if Mega_Element_CheckBox.Checked then



  if mega_element__etap_g = mee_W_Grze then
    begin

      if mega_element__poziom_g > 0 then
        ztr := Exp(  Ln( mega_element__poziom_g ) * 3  ) // Ilość składowych mega elementu.
      else//if mega_element__poziom_g > 0 then
        ztr := mega_element__poziom_g;

      Statystyki_GLHUDText.Text := Statystyki_GLHUDText.Text +
        #13 + #10 +
        odstep_c + 'me: ' + Trim(  FormatFloat( '### ### ##0', Mega_Element_Kontener_GLDummyCube.Count )  ) +
        ' / ' + Trim(  FormatFloat(   '### ### ##0', ztr )  );

      if ztr <> 0 then
        Statystyki_GLHUDText.Text := Statystyki_GLHUDText.Text +
          ' - ' + Trim(  FormatFloat( '### ### ##0.00', Mega_Element_Kontener_GLDummyCube.Count * 100 / ztr )  ) + '%'
      else//if ztr <> 0 then
        Statystyki_GLHUDText.Text := Statystyki_GLHUDText.Text +
          ' - <?>%';

      if not Gra_GLCadencer.Enabled then
        Statystyki_GLHUDText.Text := Statystyki_GLHUDText.Text +
          ' [stan mega elementu - wskaźnik procentowy (the state of the mega element - percentage indicator)]';


      if Mega_Element_Kontener_GLDummyCube.Count > 0 then // Jeżeli mega element zawiera składowe.
        Statystyki_GLHUDText.Text := Statystyki_GLHUDText.Text +
          #13 + #10 +
          odstep_c + 'meu: ' + Trim(   FormatFloat(  '### ### ##0', mega_element__ulatwienie__czas_dodania_kolejnego_sekundy_g - ( Gra_GLCadencer.CurrentTime - mega_element__ulatwienie__ostatnie_czas_g )  )   ) + ' [s]'
      else//if Mega_Element_Kontener_GLDummyCube.Count > 0 then
        Statystyki_GLHUDText.Text := Statystyki_GLHUDText.Text +
          #13 + #10 +
          odstep_c + 'meu: <n/d>';

        if not Gra_GLCadencer.Enabled then
          Statystyki_GLHUDText.Text := Statystyki_GLHUDText.Text +
            ' [ułatwienie za (facilitation in)]';

    end
  else//if mega_element__etap_g = mee_W_Grze then
    begin

      if Mega_Element_CheckBox.Checked then
        begin

          Statystyki_GLHUDText.Text := Statystyki_GLHUDText.Text +
            #13 + #10 +
            odstep_c + 'me: ' + Trim(  FormatFloat( '### ### ##0', mega_element__trafienia_licznik_g )  ) +
            ' / ' + Trim(  FormatFloat( '### ### ##0', mega_element__pojawienie_sie_ilosc_g )  ) +
            ' - ' + Trim(  FormatFloat( '### ### ##0', mega_element__pojawienie_sie_postep_procent_g )  ) + '%';

          if not Gra_GLCadencer.Enabled then
            Statystyki_GLHUDText.Text := Statystyki_GLHUDText.Text +
              ' [postęp do pojawienia się mega elementu ilość trafień / wymaganych trafień - wskaźnik procentowy' +
              #13 + #10 +
              '          (the progress to the appearance of the mega element number of hits / required hits - percentage indicator)]';

        end;
      //---//if Mega_Element_CheckBox.Checked then

    end;
  //---//if mega_element__etap_g = mee_W_Grze then



  if Gra_GLCadencer.Enabled then
    begin

      // Gra.

      Statystyki_GLHUDSprite.Visible := Statystyki_Wyswietlaj_CheckBox.Checked;
      Statystyki_GLHUDText.Visible:= Statystyki_GLHUDSprite.Visible;
      Statystyki_GLHUDText.TagFloat := Gra_GLCadencer.CurrentTime;
      //Statystyki_GLHUDSprite.Width := Length( Statystyki_GLHUDText.Text ) * 18;

    end
  else//if Gra_GLCadencer.Enabled then
    begin

      // Pauza.

      Statystyki_GLHUDText.Text := Statystyki_GLHUDText.Text +
        #13 + #10 +
        #13 + #10 +
        #13 + #10 +
        odstep_c + odstep_c + 'P - pauza (pause)' +
        #13 + #10;
        //odstep_c + odstep_c + 'LPM, shift - strzał (shoot)' +

      Statystyki_GLHUDText.Text := Statystyki_GLHUDText.Text +
        odstep_c + odstep_c + 'LPM, shift';

      if Klawisz_Dodatkowy__Strzal_Edit.Tag <> 0 then
        Statystyki_GLHUDText.Text := Statystyki_GLHUDText.Text +
          ', ' + Klawisz_Dodatkowy__Strzal_Edit.Text;

      Statystyki_GLHUDText.Text := Statystyki_GLHUDText.Text +
        ' - strzał (shoot)' +
        #13 + #10 +
        //odstep_c + odstep_c + 'PPM, ctrl - przeładowanie (reload)' +
        odstep_c + odstep_c + 'PPM, ctrl';

      if Klawisz_Dodatkowy__Przeladowanie_Edit.Tag <> 0 then
        Statystyki_GLHUDText.Text := Statystyki_GLHUDText.Text +
          ', ' + Klawisz_Dodatkowy__Przeladowanie_Edit.Text;

      Statystyki_GLHUDText.Text := Statystyki_GLHUDText.Text +
        ' - przeładowanie (reload)' +
        #13 + #10 +
        odstep_c + odstep_c + 'ŚPM, ~';

      if Klawisz_Dodatkowy__Miecz_Dobycie_Edit.Tag <> 0 then
        Statystyki_GLHUDText.Text := Statystyki_GLHUDText.Text +
          ', ' + Klawisz_Dodatkowy__Miecz_Dobycie_Edit.Text;

      Statystyki_GLHUDText.Text := Statystyki_GLHUDText.Text +
        ' - dobycie miecza (draw the sword)' +
        #13 + #10 +
        odstep_c + odstep_c + 'ESC - wyjście (exit)' +
        #13 + #10 +
        odstep_c + odstep_c + 'E - pełny ekran (full screen)' +
        #13 + #10 +
        odstep_c + odstep_c + 'Ctrl + N - nowa gra (new game)' +
        #13 + #10 +
        odstep_c + odstep_c + 'F1 - o programie, pomoc (about program, help)' +
        #13 + #10 +
        #13 + #10 +
        #13 + #10 +
        odstep_c + odstep_c + 'MIT License' +
        #13 + #10 +
        #13 + #10 +
        odstep_c + odstep_c + 'Copyright (c) 2021 Jacek Mulawka' +
        #13 + #10 +
        #13 + #10 +
        odstep_c + odstep_c + 'j.mulawka@interia.pl' +
        #13 + #10 +
        #13 + #10 +
        odstep_c + odstep_c + 'https://github.com/jacek-mulawka';

    end;
  //---//if Gra_GLCadencer.Enabled then


  if PageControl1.Visible then
    begin

      Pomoc_Label.Caption := Statystyki_GLHUDText.Text;
      Pomoc_Label.Hint := Statystyki_GLHUDText.Text;

    end;
  //---//if PageControl1.Visible then



  //Magazynek_GLHUDText.Text := '';
  Magazynek_GLHUDText.Text :=
    Trim(  FormatFloat( '### ### ##0', magazynek__pociski_ilosc_g )  );

  if magazynek__przeladowywanie_w_trakcie then
    begin

      // Przeładowywanie.

      // Współczynnik czasu przeładowania magazynka.
      if karabin_maszynowy__aktywnosc_g then
        ztr := 4
      else//if karabin_maszynowy__aktywnosc_g then
        ztr := 1;

      Magazynek_GLHUDText.Text := Magazynek_GLHUDText.Text +
        ' ... ' +
        Trim(   FormatFloat(  '### ### ##0.00', magazynek__przeladowanie__trwanie_sekundy_g * ztr - ( Gra_GLCadencer.CurrentTime - magazynek__przeladowanie__rozpoczecie_czas_g )  )   ) + ' [s]' +
        #13 + #10;

      for i := 1 to magazynek__pojemnosc_g * magazynek__mnoznik_g * karabin_maszynowy__magazynek__mnoznik_g do
        Magazynek_GLHUDText.Text := Magazynek_GLHUDText.Text +
          '-';

    end
  else//if magazynek__przeladowywanie_w_trakcie then
    begin

      // Nie przeładowuje.

      Magazynek_GLHUDText.Text := Magazynek_GLHUDText.Text +
        #13 + #10;

      for i := 1 to magazynek__pociski_ilosc_g do
        Magazynek_GLHUDText.Text := Magazynek_GLHUDText.Text +
          'o';

      for i := magazynek__pociski_ilosc_g + 1 to magazynek__pojemnosc_g * magazynek__mnoznik_g * karabin_maszynowy__magazynek__mnoznik_g do
        Magazynek_GLHUDText.Text := Magazynek_GLHUDText.Text +
          '_';

    end;
  //---//if magazynek__przeladowywanie_w_trakcie then


  Magazynek_GLHUDSprite.Width := Length( Magazynek_GLHUDText.Text ) * 18;


  if magazynek__pojemnosc_g * magazynek__mnoznik_g * karabin_maszynowy__magazynek__mnoznik_g <> 0 then
    ztr := magazynek__pociski_ilosc_g * 100 / ( magazynek__pojemnosc_g * magazynek__mnoznik_g * karabin_maszynowy__magazynek__mnoznik_g )
  else//if magazynek__pojemnosc_g * magazynek__mnoznik_g * karabin_maszynowy__magazynek__mnoznik_g <> 0 then
    ztr := 100;

  if magazynek__przeladowywanie_w_trakcie then
    Magazynek_GLHUDText.ModulateColor.Color := clrWhite
  else//if magazynek__przeladowywanie_w_trakcie then
    if ztr >= 75 then
      begin

        if karabin_maszynowy__aktywnosc_g then
          Magazynek_GLHUDText.ModulateColor.Color := clrSkyBlue
        else//if karabin_maszynowy__aktywnosc_g then
          Magazynek_GLHUDText.ModulateColor.Color := clrGreenYellow;

      end
    else
    if ztr >= 50 then
      Magazynek_GLHUDText.ModulateColor.Color := clrYellow
    else
    if ztr >= 25 then
      Magazynek_GLHUDText.ModulateColor.Color := clrOrange
    else
      Magazynek_GLHUDText.ModulateColor.Color := clrRed;



  if Przeladuj_GLHUDText.Visible then
    begin

      if magazynek__przeladowywanie_w_trakcie then
        Przeladuj_GLHUDText.ModulateColor.Color := clrGreen
      else//if magazynek__przeladowywanie_w_trakcie then
        if VectorEquals( Przeladuj_GLHUDText.ModulateColor.Color, clrRed ) then // uses GLVectorGeometry.
          Przeladuj_GLHUDText.ModulateColor.Color := clrYellow
        else//if VectorEquals( Przeladuj_GLHUDText.ModulateColor.Color, clrRed ) then
          Przeladuj_GLHUDText.ModulateColor.Color := clrRed;

      Przeladowanie_Klikniecie_GLHUDText.ModulateColor.Color := Przeladuj_GLHUDText.ModulateColor.Color;

    end
  else//if Przeladuj_GLHUDText.Visible then
    Przeladowanie_Klikniecie_GLHUDText.ModulateColor.Color := clrWhite;


  //Statystyki_GLHUDText.Text := Statystyki_GLHUDText.Text + //???
  //  #13 + #10 +
  //  odstep_c + Trim(  FormatFloat( '### ### ##0.000',  Abs( Miecz_Kontener_GLDummyCube.Position.Y + 1 )  )  ) +
  //  odstep_c + 'mee t / l: ' + Trim(  FormatFloat( '### ### ##0', mega_element__trafienia_licznik_g )  ) + ' / ' + Trim(  FormatFloat( '### ### ##0', mega_element__pojawienie_sie_ilosc_g )  ) +
  //  #13 + #10 +
  //  odstep_c + 'mee: ' + IntToStr( integer(mega_element__etap_g) ) +
  //  #13 + #10 +
  //  odstep_c + 'mee pkt il: ' + IntToStr( Mega_Element_GLThorFXManager.Maxpoints ) +
  //'';


  if Gra_GLCadencer.Enabled then
    begin

      // Gra.

      {$region 'Określa wielkości i pozycje teł napisów na ekranie.'}
      // Określa wielkość tła wyświetlanego tekstu.
      zts := Statystyki_GLHUDText.Text + #13#10;
      i := 1;
      ztr := 0;

      while i > 0 do
        begin

          i := Pos( #13#10, zts );

          if    ( i > 1 ) // Jeżeli znacznik nowej linii jest jedynym znakiem.
            and ( i > ztr ) then
            ztr := i;

          Delete( zts, 1, i + 1 );

        end;
      //---//while i > 0 do


      i := Statystyki_GLHUDText.Text.CountChar( #10 );

      if    ( i <= 0 )
        and ( ztr > 0 ) then
        i := 1;

      Statystyki_GLHUDSprite.Height := 55 * i;
      Statystyki_GLHUDSprite.Width := 18 * Round( ztr );
      //---// Określa wielkość tła wyświetlanego tekstu.
      {$endregion 'Określa wielkości i pozycje teł napisów na ekranie.'}

    end;
  //---//if Gra_GLCadencer.Enabled then


  Statystyki_GLWindowsBitmapFont.EnsureString( Statystyki_GLHUDText.Text ); // Bez tego nie ma polskich znaków.
  Statystyki_GLWindowsBitmapFont.EnsureString( Magazynek_GLHUDText.Text ); // Bez tego nie ma polskich znaków.

end;//---//Funkcja Napis_Odswiez().

//Funkcja Przeladuj_Dzwiek_Ustaw().
procedure TStrzelanka_Siekanka_Form.Przeladuj_Dzwiek_Ustaw( const dzwiek_nazwa_f : string );
var
  i : integer;
begin

  //
  // Funkcja ustawia dźwięk związany z przeładowaniem.
  //
  // Parametry:
  //   dzwiek_nazwa_f:
  //     '' - wyłącza odtwarzanie wszystkich dźwięków związanych z przeładowaniem.
  //     <niepuste> - odtwarzanie dźwięku o podanej nazwie.
  //

  if ActiveSoundManager() <> nil then
    for i := 0 to Przeladowania_Dzwieki_Emiter_GLDummyCube.Behaviours.Count - 1 do
      if Przeladowania_Dzwieki_Emiter_GLDummyCube.Behaviours.Items[ i ].ClassType = TGLBSoundEmitter then
        TGLBSoundEmitter(Przeladowania_Dzwieki_Emiter_GLDummyCube.Behaviours.Items[ i ]).Playing := TGLBSoundEmitter(Przeladowania_Dzwieki_Emiter_GLDummyCube.Behaviours.Items[ i ]).Source.SoundName = dzwiek_nazwa_f;

end;//---//Funkcja Przeladuj_Dzwiek_Ustaw().

//Funkcja Przeladuj_Komunikat_Ustaw().
procedure TStrzelanka_Siekanka_Form.Przeladuj_Komunikat_Ustaw( const widocznosc_f : boolean );
begin

  //
  // Funkcja ustawia widoczność komunikatu o przeładowaniu.
  //
  // Parametry:
  //   widocznosc_f:
  //     false - wyłącza pełny ekran.
  //     true - włącza pełny ekran.
  //

  Przeladuj_GLHUDText.Visible := widocznosc_f;
  Przeladuj_GLHUDSprite.Visible := Przeladuj_GLHUDText.Visible;

end;//---//Funkcja Przeladuj_Komunikat_Ustaw().

//Funkcja Cel__Czas_Dodania_Kolejnego_Zmien().
procedure TStrzelanka_Siekanka_Form.Cel__Czas_Dodania_Kolejnego_Zmien( const zwiekszenie_f : boolean );
begin

  //
  // Funkcja zmienia wartość modyfikatora ponawiana się celów.
  //
  // Parametry:
  //   zwiekszenie_f:
  //     false - zwiększa wartość modyfikatora ponawiana się celów.
  //     true - zmniejsza wartość modyfikatora ponawiana się celów.
  //

  if zwiekszenie_f then
    cel__czas_dodania_kolejnego_sekundy_g := cel__czas_dodania_kolejnego_sekundy_g + cel__czas_dodania_kolejnego_sekundy__modyfikator_wplyw_g // Rzadziej.
  else//if zwiekszenie_f then
    cel__czas_dodania_kolejnego_sekundy_g := cel__czas_dodania_kolejnego_sekundy_g - cel__czas_dodania_kolejnego_sekundy__modyfikator_wplyw_g; // Częściej.


  if cel__czas_dodania_kolejnego_sekundy_g < cel__czas_dodania_kolejnego_sekundy__modyfikator_wplyw_g then
    cel__czas_dodania_kolejnego_sekundy_g := cel__czas_dodania_kolejnego_sekundy__modyfikator_wplyw_g;

end;//---//Funkcja Cel__Czas_Dodania_Kolejnego_Zmien().

//Funkcja Cel__Ruch_Szbkosc_Zmien().
procedure TStrzelanka_Siekanka_Form.Cel__Ruch_Szbkosc_Zmien( const zwiekszenie_f : boolean );
begin

  //
  // Funkcja zmienia wartość modyfikatora lotu się celów.
  //
  // Parametry:
  //   zwiekszenie_f:
  //     false - zwiększa wartość modyfikatora lotu celów.
  //     true - zmniejsza wartość modyfikatora lotu celów.
  //

  if zwiekszenie_f then
    cel__ruch_szybkosc_g := cel__ruch_szybkosc_g + cel__ruch_szybkosc__modyfikator_wplyw_g // Szybciej.
  else//if zwiekszenie_f then
    cel__ruch_szybkosc_g := cel__ruch_szybkosc_g - cel__ruch_szybkosc__modyfikator_wplyw_g; // Wolniej.


  if cel__ruch_szybkosc_g < cel__ruch_szybkosc__modyfikator_wplyw_g then
    cel__ruch_szybkosc_g := cel__ruch_szybkosc__modyfikator_wplyw_g;

end;//---//Funkcja Cel__Ruch_Szbkosc_Zmien().

//Funkcja Karabin_Maszynowy_Zmien().
procedure TStrzelanka_Siekanka_Form.Karabin_Maszynowy_Zmien( const aktywny_f : boolean );
begin

  //
  // Funkcja zmienia aktywność trybu karabinu maszynowego.
  //
  // Parametry:
  //   aktywny_f:
  //     fale - tryb karabinu maszynowego nieaktywny.
  //     true - tryb karabinu maszynowego aktywny.
  //

  //if karabin_maszynowy__aktywnosc_g = aktywny_f then
  //  Exit;

  if karabin_maszynowy__aktywnosc_g <> aktywny_f then
    karabin_maszynowy__aktywnosc_g := aktywny_f;

  karabin_maszynowy__utworzenie_czas_g := Gra_GLCadencer.CurrentTime;


  if aktywny_f then
    begin

      karabin_maszynowy__magazynek__mnoznik_g := 10;
      magazynek__pociski_ilosc_g := magazynek__pojemnosc_g * magazynek__mnoznik_g * karabin_maszynowy__magazynek__mnoznik_g;
      Przeladuj_Komunikat_Ustaw( false );
      Przeladuj_Dzwiek_Ustaw( '' );

    end
  else//if aktywny_f then
    begin

      karabin_maszynowy__magazynek__mnoznik_g := 1;

      if magazynek__pociski_ilosc_g > 0 then
        magazynek__pociski_ilosc_g := magazynek__pojemnosc_g * magazynek__mnoznik_g * karabin_maszynowy__magazynek__mnoznik_g;

    end;
  //---//if aktywny_f then


  if magazynek__pociski_ilosc_g > magazynek__pojemnosc_g * magazynek__mnoznik_g * karabin_maszynowy__magazynek__mnoznik_g then
    magazynek__pociski_ilosc_g := magazynek__pojemnosc_g * magazynek__mnoznik_g * karabin_maszynowy__magazynek__mnoznik_g
  else
  if magazynek__pociski_ilosc_g < 0 then
    magazynek__pociski_ilosc_g := 0;


  Napis_Odswiez( true );

end;//---//Funkcja Karabin_Maszynowy_Zmien().

//Funkcja Magazynek__Mnoznik_Zmien().
procedure TStrzelanka_Siekanka_Form.Magazynek__Mnoznik_Zmien( const kierunek_f : smallint );
var
  ztr : real;
begin

  //
  // Funkcja zmienia pojemność magazynka o zadaną ilość razy.
  //
  // Parametry:
  //   kierunek_f:
  //     0 > - zwiększa pojemność magazynka.
  //     <= 0 - zmniejsza pojemność magazynka.
  //

  if   (
             ( magazynek__mnoznik_g = 1 )
         and ( kierunek_f < 0 )  // Mnożnik magazynka nie może być mniejszy równy zero.
       )
    or ( kierunek_f = 0 ) then // Zero nie zmienia mnożnika magazynka.
    Exit;


  // Magazynek jest wypełniony w takim procencie.
  if magazynek__pociski_ilosc_g * magazynek__mnoznik_g * karabin_maszynowy__magazynek__mnoznik_g <> 0 then
    ztr := magazynek__pociski_ilosc_g * 100 / ( magazynek__pociski_ilosc_g * magazynek__mnoznik_g * karabin_maszynowy__magazynek__mnoznik_g )
  else//if magazynek__pociski_ilosc_g * magazynek__mnoznik_g * karabin_maszynowy__magazynek__mnoznik_g <> 0 then
    ztr := 1;

  magazynek__mnoznik_g := magazynek__mnoznik_g + kierunek_f;

  magazynek__pociski_ilosc_g := Round( magazynek__pociski_ilosc_g * magazynek__mnoznik_g * karabin_maszynowy__magazynek__mnoznik_g * ztr * 0.01 );


  if magazynek__pociski_ilosc_g > magazynek__pojemnosc_g * magazynek__mnoznik_g * karabin_maszynowy__magazynek__mnoznik_g then
    magazynek__pociski_ilosc_g := magazynek__pojemnosc_g * magazynek__mnoznik_g * karabin_maszynowy__magazynek__mnoznik_g
  else
  if magazynek__pociski_ilosc_g < 0 then
    magazynek__pociski_ilosc_g := 0;


  magazynek__mnoznik__utworzenie_czas_g := Gra_GLCadencer.CurrentTime;


  Napis_Odswiez( true );

end;//---//Funkcja Magazynek__Mnoznik_Zmien().

//Funkcja Mega_Element_Efekt_Wylicz().
procedure TStrzelanka_Siekanka_Form.Mega_Element_Efekt_Wylicz();
var
  zti : integer;
begin

  //
  // Funkcja ustala wygląd efektu określającego nadejście mega elementu.
  //

  if mega_element__trafienia_licznik_g > mega_element__pojawienie_sie_ilosc_g then
    zti := mega_element__pojawienie_sie_ilosc_g
  else//if mega_element__trafienia_licznik_g > mega_element__pojawienie_sie_ilosc_g then
    zti := mega_element__trafienia_licznik_g;


  if mega_element__etap_g in [ mee_W_Grze, mee_Runda_Zakonczona ] then
    mega_element__pojawienie_sie_postep_procent_g := 100
  else//if mega_element__etap_g in [ mee_W_Grze, mee_Runda_Zakonczona ] then
    if Mega_Element_CheckBox.Checked then
      mega_element__pojawienie_sie_postep_procent_g := zti * 100 / mega_element__pojawienie_sie_ilosc_g
  else//if Mega_Element_CheckBox.Checked then
    mega_element__pojawienie_sie_postep_procent_g := 0;


  if mega_element__pojawienie_sie_ilosc_g <> 0 then
    Mega_Element_GLThorFXManager.Maxpoints :=
      Ceil
        (
          Gra_GLSceneViewer.Width * 0.001 // Ilość punktów względem szerokości ekranu gry.
          //* zti * 100 / mega_element__pojawienie_sie_ilosc_g // Postęp wyrażony w procencie.
          * mega_element__pojawienie_sie_postep_procent_g
        )
        + 1 // Nie może być zero punktów.
  else//if mega_element__pojawienie_sie_ilosc_g <> 0 then
    Mega_Element_GLThorFXManager.Maxpoints := Ceil( Gra_GLSceneViewer.Width * 0.2 );

end;//---/Mega_Element_Efekt_Wylicz().

//Funkcja Mega_Element_Zatrzymaj().
procedure TStrzelanka_Siekanka_Form.Mega_Element_Zatrzymaj();
var
  zti : smallint;
begin

  //
  // Funkcja zeruje siły działające na mega element i przenosi go ponad ekran gry.
  //

  GetOrCreateInertia( Mega_Element_Kontener_GLDummyCube ).TranslationSpeed.SetToZero();
  GetOrCreateInertia( Mega_Element_Kontener_GLDummyCube ).PitchSpeed := 0;
  GetOrCreateInertia( Mega_Element_Kontener_GLDummyCube ).RollSpeed := 0;
  GetOrCreateInertia( Mega_Element_Kontener_GLDummyCube ).TurnSpeed := 0;

  Mega_Element_Kontener_GLDummyCube.Position.Y := ekran_margines__istnienie__gora_dol_g * 2;


  zti := Mega_Element_Kontener_GLDummyCube.Behaviours.IndexOfClass( TGLBSoundEmitter ); // -1 - brak, >= 0 zachowania.

  if    ( zti >= 0 )
    and ( ActiveSoundManager() <> nil )then
    TGLBSoundEmitter(Mega_Element_Kontener_GLDummyCube.Behaviours.Items[ zti ]).Playing := false;

end;//---//Funkcja Mega_Element_Zatrzymaj().

//Funkcja Ustawienia_Plik().
procedure TStrzelanka_Siekanka_Form.Ustawienia_Plik( const zapisuj_ustawienia_f : boolean = false );
var
  plik_ini : TIniFile; // uses IniFiles.
  zti : integer;
  zts : string;
begin

  //
  // Funkcja wczytuje i zapisuje ustawienia.
  //
  // Parametry:
  //   zapisuj_ustawienia_f:
  //     false - tylko odczytuje ustawienia.
  //     true - zapisuje ustawienia.
  //

  zts := ExtractFilePath( Application.ExeName ) + 'Strzelanka Siekanka.ini';

  plik_ini := TIniFile.Create( zts );


  if   (  zapisuj_ustawienia_f )
    or (  not plik_ini.ValueExists( 'KLAWIATURA_KONFIGURACJA', 'miecz_dobycie' )  ) then
    plik_ini.WriteInteger( 'KLAWIATURA_KONFIGURACJA', 'miecz_dobycie', Klawisz_Dodatkowy__Miecz_Dobycie_Edit.Tag )
  else
    Klawisz_Dodatkowy__Miecz_Dobycie_Edit.Tag := plik_ini.ReadInteger( 'KLAWIATURA_KONFIGURACJA', 'miecz_dobycie', Klawisz_Dodatkowy__Miecz_Dobycie_Edit.Tag ); // Jeżeli nie znajdzie to podstawia wartość Klawisz_Dodatkowy__Miecz_Dobycie_Edit.Tag.

  if   (  zapisuj_ustawienia_f )
    or (  not plik_ini.ValueExists( 'KLAWIATURA_KONFIGURACJA', 'przeładowanie' )  ) then
    plik_ini.WriteInteger( 'KLAWIATURA_KONFIGURACJA', 'przeładowanie', Klawisz_Dodatkowy__Przeladowanie_Edit.Tag )
  else
    Klawisz_Dodatkowy__Przeladowanie_Edit.Tag := plik_ini.ReadInteger( 'KLAWIATURA_KONFIGURACJA', 'przeładowanie', Klawisz_Dodatkowy__Przeladowanie_Edit.Tag ); // Jeżeli nie znajdzie to podstawia wartość Klawisz_Dodatkowy__Przeladowanie_Edit.Tag.

  if   (  zapisuj_ustawienia_f )
    or (  not plik_ini.ValueExists( 'KLAWIATURA_KONFIGURACJA', 'strzał' )  ) then
    plik_ini.WriteInteger( 'KLAWIATURA_KONFIGURACJA', 'strzał', Klawisz_Dodatkowy__Strzal_Edit.Tag )
  else
    Klawisz_Dodatkowy__Strzal_Edit.Tag := plik_ini.ReadInteger( 'KLAWIATURA_KONFIGURACJA', 'strzał', Klawisz_Dodatkowy__Strzal_Edit.Tag ); // Jeżeli nie znajdzie to podstawia wartość Klawisz_Dodatkowy__Strzal_Edit.Tag.


  {$region 'PARAMETRY.'}
  if   (  zapisuj_ustawienia_f )
    or (  not plik_ini.ValueExists( 'PARAMETRY', 'cel__czas_dodania_kolejnego_sekundy__modyfikator_wpływ' )  ) then
    plik_ini.WriteFloat( 'PARAMETRY', 'cel__czas_dodania_kolejnego_sekundy__modyfikator_wpływ', cel__czas_dodania_kolejnego_sekundy__modyfikator_wplyw_g )
  else
    cel__czas_dodania_kolejnego_sekundy__modyfikator_wplyw_g := plik_ini.ReadFloat( 'PARAMETRY', 'cel__czas_dodania_kolejnego_sekundy__modyfikator_wpływ', cel__czas_dodania_kolejnego_sekundy__modyfikator_wplyw_g ); // Jeżeli nie znajdzie to podstawia wartość cel__czas_dodania_kolejnego_sekundy__modyfikator_wplyw_g.

  if   (  zapisuj_ustawienia_f )
    or (  not plik_ini.ValueExists( 'PARAMETRY', 'cel__czas_dodania_kolejnego_sekundy__początkowe' )  ) then
    plik_ini.WriteFloat( 'PARAMETRY', 'cel__czas_dodania_kolejnego_sekundy__początkowe', cel__czas_dodania_kolejnego_sekundy__poczatkowe_g )
  else
    cel__czas_dodania_kolejnego_sekundy__poczatkowe_g := plik_ini.ReadFloat( 'PARAMETRY', 'cel__czas_dodania_kolejnego_sekundy__początkowe', cel__czas_dodania_kolejnego_sekundy__poczatkowe_g ); // Jeżeli nie znajdzie to podstawia wartość cel__czas_dodania_kolejnego_sekundy__poczatkowe_g.

  if   (  zapisuj_ustawienia_f )
    or (  not plik_ini.ValueExists( 'PARAMETRY', 'cel__czas_trwania_sekundy' )  ) then
    plik_ini.WriteFloat( 'PARAMETRY', 'cel__czas_trwania_sekundy', cel__czas_trwania_sekundy_g )
  else
    cel__czas_trwania_sekundy_g := plik_ini.ReadFloat( 'PARAMETRY', 'cel__czas_trwania_sekundy', cel__czas_trwania_sekundy_g ); // Jeżeli nie znajdzie to podstawia wartość cel__czas_trwania_sekundy_g.

  if   (  zapisuj_ustawienia_f )
    or (  not plik_ini.ValueExists( 'PARAMETRY', 'cel__dystans_trwania' )  ) then
    plik_ini.WriteFloat( 'PARAMETRY', 'cel__dystans_trwania', cel__dystans_trwania_g )
  else
    cel__dystans_trwania_g := plik_ini.ReadFloat( 'PARAMETRY', 'cel__dystans_trwania', cel__dystans_trwania_g ); // Jeżeli nie znajdzie to podstawia wartość cel__dystans_trwania_g.

  if   (  zapisuj_ustawienia_f )
    or (  not plik_ini.ValueExists( 'PARAMETRY', 'cel__ruch_szybkość__modyfikator_wpływ' )  ) then
    plik_ini.WriteFloat( 'PARAMETRY', 'cel__ruch_szybkość__modyfikator_wpływ', cel__ruch_szybkosc__modyfikator_wplyw_g )
  else
    cel__ruch_szybkosc__modyfikator_wplyw_g := plik_ini.ReadFloat( 'PARAMETRY', 'cel__ruch_szybkość__modyfikator_wpływ', cel__ruch_szybkosc__modyfikator_wplyw_g ); // Jeżeli nie znajdzie to podstawia wartość cel__ruch_szybkosc__modyfikator_wplyw_g.

  if   (  zapisuj_ustawienia_f )
    or (  not plik_ini.ValueExists( 'PARAMETRY', 'cel__ruch_szybkość__początkowe' )  ) then
    plik_ini.WriteFloat( 'PARAMETRY', 'cel__ruch_szybkość__początkowe', cel__ruch_szybkosc__poczatkowe_g )
  else
    cel__ruch_szybkosc__poczatkowe_g := plik_ini.ReadFloat( 'PARAMETRY', 'cel__ruch_szybkość__początkowe', cel__ruch_szybkosc__poczatkowe_g ); // Jeżeli nie znajdzie to podstawia wartość cel__ruch_szybkosc__poczatkowe_g.

  if   (  zapisuj_ustawienia_f )
    or (  not plik_ini.ValueExists( 'PARAMETRY', 'karabin_maszynowy__trwanie_sekundy' )  ) then
    plik_ini.WriteFloat( 'PARAMETRY', 'karabin_maszynowy__trwanie_sekundy', karabin_maszynowy__trwanie_sekundy_g )
  else
    karabin_maszynowy__trwanie_sekundy_g := plik_ini.ReadFloat( 'PARAMETRY', 'karabin_maszynowy__trwanie_sekundy', karabin_maszynowy__trwanie_sekundy_g ); // Jeżeli nie znajdzie to podstawia wartość karabin_maszynowy__trwanie_sekundy_g.

  if   (  zapisuj_ustawienia_f )
    or (  not plik_ini.ValueExists( 'PARAMETRY', 'magazynek__pojemność' )  ) then
    plik_ini.WriteInteger( 'PARAMETRY', 'magazynek__pojemność', magazynek__pojemnosc_g )
  else
    magazynek__pojemnosc_g := plik_ini.ReadInteger( 'PARAMETRY', 'magazynek__pojemność', magazynek__pojemnosc_g ); // Jeżeli nie znajdzie to podstawia wartość magazynek__pojemnosc_g.

  if   (  zapisuj_ustawienia_f )
    or (  not plik_ini.ValueExists( 'PARAMETRY', 'magazynek__przeładowanie__trwanie_sekundy' )  ) then
    plik_ini.WriteFloat( 'PARAMETRY', 'magazynek__przeładowanie__trwanie_sekundy', magazynek__przeladowanie__trwanie_sekundy_g )
  else
    magazynek__przeladowanie__trwanie_sekundy_g := plik_ini.ReadFloat( 'PARAMETRY', 'magazynek__przeładowanie__trwanie_sekundy', magazynek__przeladowanie__trwanie_sekundy_g ); // Jeżeli nie znajdzie to podstawia wartość magazynek__przeladowanie__trwanie_sekundy_g.

  if   (  zapisuj_ustawienia_f )
    or (  not plik_ini.ValueExists( 'PARAMETRY', 'magazynek__mnożnik__trwanie_sekundy' )  ) then
    plik_ini.WriteFloat( 'PARAMETRY', 'magazynek__mnożnik__trwanie_sekundy', magazynek__mnoznik__trwanie_sekundy_g )
  else
    magazynek__mnoznik__trwanie_sekundy_g := plik_ini.ReadFloat( 'PARAMETRY', 'magazynek__mnożnik__trwanie_sekundy', magazynek__mnoznik__trwanie_sekundy_g ); // Jeżeli nie znajdzie to podstawia wartość magazynek__mnoznik__trwanie_sekundy_g.

  if   (  zapisuj_ustawienia_f )
    or (  not plik_ini.ValueExists( 'PARAMETRY', 'mega_element__czas_trwania_sekundy' )  ) then
    plik_ini.WriteFloat( 'PARAMETRY', 'mega_element__czas_trwania_sekundy', mega_element__czas_trwania_sekundy_g )
  else
    mega_element__czas_trwania_sekundy_g := plik_ini.ReadFloat( 'PARAMETRY', 'mega_element__czas_trwania_sekundy', mega_element__czas_trwania_sekundy_g ); // Jeżeli nie znajdzie to podstawia wartość mega_element__czas_trwania_sekundy_g.

  if   (  zapisuj_ustawienia_f )
    or (  not plik_ini.ValueExists( 'PARAMETRY', 'mega_element__pojawienie_się_ilość' )  ) then
    plik_ini.WriteInteger( 'PARAMETRY', 'mega_element__pojawienie_się_ilość', mega_element__pojawienie_sie_ilosc_g )
  else
    mega_element__pojawienie_sie_ilosc_g := plik_ini.ReadInteger( 'PARAMETRY', 'mega_element__pojawienie_się_ilość', mega_element__pojawienie_sie_ilosc_g ); // Jeżeli nie znajdzie to podstawia wartość mega_element__pojawienie_sie_ilosc_g.

  if   (  zapisuj_ustawienia_f )
    or (  not plik_ini.ValueExists( 'PARAMETRY', 'mega_element__poziom__początkowe' )  ) then
    plik_ini.WriteInteger( 'PARAMETRY', 'mega_element__poziom__początkowe', mega_element__poziom__poczatkowe_g )
  else
    mega_element__poziom__poczatkowe_g := plik_ini.ReadInteger( 'PARAMETRY', 'mega_element__poziom__początkowe', mega_element__poziom__poczatkowe_g ); // Jeżeli nie znajdzie to podstawia wartość mega_element__poziom__poczatkowe_g.

  if   (  zapisuj_ustawienia_f )
    or (  not plik_ini.ValueExists( 'PARAMETRY', 'mega_element__ułatwienie__czas_dodania_kolejnego_sekundy' )  ) then
    plik_ini.WriteFloat( 'PARAMETRY', 'mega_element__ułatwienie__czas_dodania_kolejnego_sekundy', mega_element__ulatwienie__czas_dodania_kolejnego_sekundy_g )
  else
    mega_element__ulatwienie__czas_dodania_kolejnego_sekundy_g := plik_ini.ReadFloat( 'PARAMETRY', 'mega_element__ułatwienie__czas_dodania_kolejnego_sekundy', mega_element__ulatwienie__czas_dodania_kolejnego_sekundy_g ); // Jeżeli nie znajdzie to podstawia wartość mega_element__ulatwienie__czas_dodania_kolejnego_sekundy_g.

  if   (  zapisuj_ustawienia_f )
    or (  not plik_ini.ValueExists( 'PARAMETRY', 'pocisk__czas_trwania_sekundy' )  ) then
    plik_ini.WriteFloat( 'PARAMETRY', 'pocisk__czas_trwania_sekundy', pocisk__czas_trwania_sekundy_g )
  else
    pocisk__czas_trwania_sekundy_g := plik_ini.ReadFloat( 'PARAMETRY', 'pocisk__czas_trwania_sekundy', pocisk__czas_trwania_sekundy_g ); // Jeżeli nie znajdzie to podstawia wartość pocisk__czas_trwania_sekundy_g.

  if   (  zapisuj_ustawienia_f )
    or (  not plik_ini.ValueExists( 'PARAMETRY', 'pocisk__dystans_trwania' )  ) then
    plik_ini.WriteFloat( 'PARAMETRY', 'pocisk__dystans_trwania', pocisk__dystans_trwania_g )
  else
    pocisk__dystans_trwania_g := plik_ini.ReadFloat( 'PARAMETRY', 'pocisk__dystans_trwania', pocisk__dystans_trwania_g ); // Jeżeli nie znajdzie to podstawia wartość pocisk__dystans_trwania_g.

  if   (  zapisuj_ustawienia_f )
    or (  not plik_ini.ValueExists( 'PARAMETRY', 'pocisk__przeładowanie_trwanie' )  ) then
    plik_ini.WriteFloat( 'PARAMETRY', 'pocisk__przeładowanie_trwanie', pocisk__przeladowanie_trwanie_g )
  else
    pocisk__przeladowanie_trwanie_g := plik_ini.ReadFloat( 'PARAMETRY', 'pocisk__przeładowanie_trwanie', pocisk__przeladowanie_trwanie_g ); // Jeżeli nie znajdzie to podstawia wartość pocisk__przeladowanie_trwanie_g.

  if   (  zapisuj_ustawienia_f )
    or (  not plik_ini.ValueExists( 'PARAMETRY', 'pocisk__ruch_szybkość' )  ) then
    plik_ini.WriteFloat( 'PARAMETRY', 'pocisk__ruch_szybkość', pocisk__ruch_szybkosc_g )
  else
    pocisk__ruch_szybkosc_g := plik_ini.ReadFloat( 'PARAMETRY', 'pocisk__ruch_szybkość', pocisk__ruch_szybkosc_g ); // Jeżeli nie znajdzie to podstawia wartość pocisk__ruch_szybkosc_g.
  {$endregion 'PARAMETRY.'}

  {$region 'USTAWIENIA.'}
  zti := Glosnosc_SpinEdit.Value;

  if   (  zapisuj_ustawienia_f )
    or (  not plik_ini.ValueExists( 'USTAWIENIA', 'głośność_poziom' )  ) then
    plik_ini.WriteInteger( 'USTAWIENIA', 'głośność_poziom', zti )
  else
    zti := plik_ini.ReadInteger( 'USTAWIENIA', 'głośność_poziom', zti ); // Jeżeli nie znajdzie to podstawia wartość zti.

  if zti > Glosnosc_SpinEdit.MaxValue then
    zti := Glosnosc_SpinEdit.MaxValue
  else//if zti >= Glosnosc_SpinEdit.MaxValue then
  if zti < Glosnosc_SpinEdit.MinValue then
    zti := Glosnosc_SpinEdit.MinValue;

  Glosnosc_SpinEdit.Value := zti;



  if Magazynek_Wyswietlaj_CheckBox.Checked then
    zts := 'tak'
  else//if Magazynek_Wyswietlaj_CheckBox.Checked then
    zts := 'nie';

  if   (  zapisuj_ustawienia_f )
    or (  not plik_ini.ValueExists( 'USTAWIENIA', 'magazynek_wyświetlaj' )  ) then
    plik_ini.WriteString( 'USTAWIENIA', 'magazynek_wyświetlaj', zts )
  else
    zts := plik_ini.ReadString( 'USTAWIENIA', 'magazynek_wyświetlaj', zts ); // Jeżeli nie znajdzie to podstawia wartość zts.

  Magazynek_Wyswietlaj_CheckBox.Checked := zts = 'tak';



  if Mega_Element_CheckBox.Checked then
    zts := 'tak'
  else//if Mega_Element_CheckBox.Checked then
    zts := 'nie';

  if   (  zapisuj_ustawienia_f )
    or (  not plik_ini.ValueExists( 'USTAWIENIA', 'mega_element' )  ) then
    plik_ini.WriteString( 'USTAWIENIA', 'mega_element', zts )
  else
    zts := plik_ini.ReadString( 'USTAWIENIA', 'mega_element', zts ); // Jeżeli nie znajdzie to podstawia wartość zts.

  Mega_Element_CheckBox.Checked := zts = 'tak';



  if Miecz_Dobycie_CheckBox.Checked then
    zts := 'tak'
  else//if Miecz_Dobycie_CheckBox.Checked then
    zts := 'nie';

  if   (  zapisuj_ustawienia_f )
    or (  not plik_ini.ValueExists( 'USTAWIENIA', 'miecz_dobycie_widoczność' )  ) then
    plik_ini.WriteString( 'USTAWIENIA', 'miecz_dobycie_widoczność', zts )
  else
    zts := plik_ini.ReadString( 'USTAWIENIA', 'miecz_dobycie_widoczność', zts ); // Jeżeli nie znajdzie to podstawia wartość zts.

  Miecz_Dobycie_CheckBox.Checked := zts = 'tak';



  zti := Miecz_Dobycie_Wielkosc_SpinEdit.Value;

  if   (  zapisuj_ustawienia_f )
    or (  not plik_ini.ValueExists( 'USTAWIENIA', 'miecz_dobycie_wielkość' )  ) then
    plik_ini.WriteInteger( 'USTAWIENIA', 'miecz_dobycie_wielkość', zti )
  else
    zti := plik_ini.ReadInteger( 'USTAWIENIA', 'miecz_dobycie_wielkość', zti ); // Jeżeli nie znajdzie to podstawia wartość zti.

  if zti >= Miecz_Dobycie_Wielkosc_SpinEdit.MinValue then
    Miecz_Dobycie_Wielkosc_SpinEdit.Value := zti
  else//if zti >= Miecz_Dobycie_Wielkosc_SpinEdit.MinValue then
    Miecz_Dobycie_Wielkosc_SpinEdit.Value := Miecz_Dobycie_Wielkosc_SpinEdit.MinValue;



  if Mysz_Ciagle_Strzelanie_CheckBox.Checked then
    zts := 'tak'
  else//if Mysz_Ciagle_Strzelanie_CheckBox.Checked then
    zts := 'nie';

  if   (  zapisuj_ustawienia_f )
    or (  not plik_ini.ValueExists( 'USTAWIENIA', 'mysz_ciągłe_strzelanie' )  ) then
    plik_ini.WriteString( 'USTAWIENIA', 'mysz_ciągłe_strzelanie', zts )
  else
    zts := plik_ini.ReadString( 'USTAWIENIA', 'mysz_ciągłe_strzelanie', zts ); // Jeżeli nie znajdzie to podstawia wartość zts.

  Mysz_Ciagle_Strzelanie_CheckBox.Checked := zts = 'tak';



  if Self.BorderStyle = bsNone then
    zts := 'tak'
  else//if Self.BorderStyle s= bsNone then
    zts := 'nie';

  if   (  zapisuj_ustawienia_f )
    or (  not plik_ini.ValueExists( 'USTAWIENIA', 'pełny_ekran' )  ) then
    plik_ini.WriteString( 'USTAWIENIA', 'pełny_ekran', zts )
  else
    zts := plik_ini.ReadString( 'USTAWIENIA', 'pełny_ekran', zts ); // Jeżeli nie znajdzie to podstawia wartość zts.

  if zts = 'tak' then
    Pelny_Ekran( true );



  if Przeladowanie_Klikniecie_CheckBox.Checked then
    zts := 'tak'
  else//if Przeladowanie_Klikniecie_CheckBox.Checked then
    zts := 'nie';

  if   (  zapisuj_ustawienia_f )
    or (  not plik_ini.ValueExists( 'USTAWIENIA', 'przeładowanie_kliknięcie_widoczność' )  ) then
    plik_ini.WriteString( 'USTAWIENIA', 'przeładowanie_kliknięcie_widoczność', zts )
  else
    zts := plik_ini.ReadString( 'USTAWIENIA', 'przeładowanie_kliknięcie_widoczność', zts ); // Jeżeli nie znajdzie to podstawia wartość zts.

  Przeladowanie_Klikniecie_CheckBox.Checked := zts = 'tak';



  zti := Przeladowanie_Klikniecie_Wielkosc_SpinEdit.Value;

  if   (  zapisuj_ustawienia_f )
    or (  not plik_ini.ValueExists( 'USTAWIENIA', 'przeładowanie_kliknięcie_wielkość' )  ) then
    plik_ini.WriteInteger( 'USTAWIENIA', 'przeładowanie_kliknięcie_wielkość', zti )
  else
    zti := plik_ini.ReadInteger( 'USTAWIENIA', 'przeładowanie_kliknięcie_wielkość', zti ); // Jeżeli nie znajdzie to podstawia wartość zti.

  if zti >= Przeladowanie_Klikniecie_Wielkosc_SpinEdit.MinValue then
    Przeladowanie_Klikniecie_Wielkosc_SpinEdit.Value := zti
  else//if zti >= Przeladowanie_Klikniecie_Wielkosc_SpinEdit.MinValue then
    Przeladowanie_Klikniecie_Wielkosc_SpinEdit.Value := Przeladowanie_Klikniecie_Wielkosc_SpinEdit.MinValue;



  if Start_Z_Pauza_CheckBox.Checked then
    zts := 'tak'
  else//if Start_Z_Pauza_CheckBox.Checked then
    zts := 'nie';

  if   (  zapisuj_ustawienia_f )
    or (  not plik_ini.ValueExists( 'USTAWIENIA', 'start_z_pauzą' )  ) then
    plik_ini.WriteString( 'USTAWIENIA', 'start_z_pauzą', zts )
  else
    zts := plik_ini.ReadString( 'USTAWIENIA', 'start_z_pauzą', zts ); // Jeżeli nie znajdzie to podstawia wartość zts.

  Start_Z_Pauza_CheckBox.Checked := zts = 'tak';




  if Statystyki_Wyswietlaj_CheckBox.Checked then
    zts := 'tak'
  else//if Statystyki_Wyswietlaj_CheckBox.Checked then
    zts := 'nie';

  if   (  zapisuj_ustawienia_f )
    or (  not plik_ini.ValueExists( 'USTAWIENIA', 'statystyki_wyświetlaj' )  ) then
    plik_ini.WriteString( 'USTAWIENIA', 'statystyki_wyświetlaj', zts )
  else
    zts := plik_ini.ReadString( 'USTAWIENIA', 'statystyki_wyświetlaj', zts ); // Jeżeli nie znajdzie to podstawia wartość zts.

  Statystyki_Wyswietlaj_CheckBox.Checked := zts = 'tak';



  if Ukryte_Funkcje_Zezwalaj_CheckBox.Checked then
    zts := 'tak'
  else//if Ukryte_Funkcje_Zezwalaj_CheckBox.Checked then
    zts := 'nie';

  if   (  zapisuj_ustawienia_f )
    or (  not plik_ini.ValueExists( 'USTAWIENIA', 'ukryte_funkcje_zezwalaj' )  ) then
    plik_ini.WriteString( 'USTAWIENIA', 'ukryte_funkcje_zezwalaj', zts )
  else
    zts := plik_ini.ReadString( 'USTAWIENIA', 'ukryte_funkcje_zezwalaj', zts ); // Jeżeli nie znajdzie to podstawia wartość zts.

  Ukryte_Funkcje_Zezwalaj_CheckBox.Checked := zts = 'tak';
  {$endregion 'USTAWIENIA.'}

  plik_ini.Free();

  {$region 'Sprawdza czy wartości nie są zbyt małe.'}
  if cel__czas_dodania_kolejnego_sekundy__modyfikator_wplyw_g < 0 then
    cel__czas_dodania_kolejnego_sekundy__modyfikator_wplyw_g := 0.1;

  if cel__czas_dodania_kolejnego_sekundy__poczatkowe_g < 0 then
    cel__czas_dodania_kolejnego_sekundy__poczatkowe_g := 3;

  if cel__czas_trwania_sekundy_g <= 0 then
    cel__czas_trwania_sekundy_g := 60;

  if cel__dystans_trwania_g <= 0 then
    cel__dystans_trwania_g := 120;

  if cel__ruch_szybkosc__modyfikator_wplyw_g < 0 then
    cel__ruch_szybkosc__modyfikator_wplyw_g := 0.1;

  if cel__ruch_szybkosc__poczatkowe_g < 0 then
    cel__ruch_szybkosc__poczatkowe_g := 2;

  if karabin_maszynowy__trwanie_sekundy_g <= 0 then
    karabin_maszynowy__trwanie_sekundy_g := 60;

  if magazynek__pojemnosc_g <= 0 then
    magazynek__pojemnosc_g := 12;

  if magazynek__przeladowanie__trwanie_sekundy_g <= 0 then
    magazynek__przeladowanie__trwanie_sekundy_g := 1.5;

  if magazynek__mnoznik__trwanie_sekundy_g <= 0 then
    magazynek__mnoznik__trwanie_sekundy_g := 120;

  if mega_element__czas_trwania_sekundy_g <= 0 then
    mega_element__czas_trwania_sekundy_g := 12000;

  if mega_element__pojawienie_sie_ilosc_g <= 0 then
    mega_element__pojawienie_sie_ilosc_g := 100;

  if mega_element__poziom__poczatkowe_g < 0 then
    mega_element__poziom__poczatkowe_g := 0;

  if mega_element__ulatwienie__czas_dodania_kolejnego_sekundy_g <= 0 then
    mega_element__ulatwienie__czas_dodania_kolejnego_sekundy_g := 60;

  if pocisk__czas_trwania_sekundy_g <= 0 then
    pocisk__czas_trwania_sekundy_g := 60;

  if pocisk__dystans_trwania_g <= 0 then
    pocisk__dystans_trwania_g := 600;

  if pocisk__przeladowanie_trwanie_g <= 0 then
    pocisk__przeladowanie_trwanie_g := 0.25;

  if pocisk__ruch_szybkosc_g <= 0 then
    pocisk__ruch_szybkosc_g := 28;
  {$endregion 'Sprawdza czy wartości nie są zbyt małe.'}


  Klawisz_Dodatkowy__Nazwa_Ustal( Klawisz_Dodatkowy__Miecz_Dobycie_Edit );
  Klawisz_Dodatkowy__Nazwa_Ustal( Klawisz_Dodatkowy__Przeladowanie_Edit );
  Klawisz_Dodatkowy__Nazwa_Ustal( Klawisz_Dodatkowy__Strzal_Edit );

end;//---//Funkcja Ustawienia_Plik().

//Funkcja Klawisz_Dodatkowy__Nazwa_Ustal().
procedure TStrzelanka_Siekanka_Form.Klawisz_Dodatkowy__Nazwa_Ustal( const edit_f : TEdit );
begin

  if   ( edit_f = nil )
    or (  not Assigned( edit_f )  ) then
    Exit;


  if edit_f.Tag <> 0 then
    edit_f.Text := GLKeyboard.VirtualKeyCodeToKeyName( edit_f.Tag )
  else//if edit_f.Tag <> 0 then
    edit_f.Text := '<brak [none]>';


  Napis_Odswiez( true );


  if   ( edit_f.Tag = VK_ADD )
    or ( edit_f.Tag = VK_CONTROL )
    or ( edit_f.Tag = VK_ESCAPE )
    or ( edit_f.Tag = VK_F1 )
    or ( edit_f.Tag = VK_NUMPAD0 )
    or ( edit_f.Tag = VK_NUMPAD1 )
    or ( edit_f.Tag = VK_NUMPAD2 )
    or ( edit_f.Tag = VK_NUMPAD7 )
    or ( edit_f.Tag = VK_NUMPAD8 )
    or ( edit_f.Tag = VK_NUMPAD9 )
    or ( edit_f.Tag = VK_SHIFT )
    or ( edit_f.Tag = VK_SUBTRACT )
    //or (  edit_f.Tag = Ord( 'N' )  ) // ( ssCtrl in Shift )
    //or (  edit_f.Tag = Ord( '~' )  ) // Tyldę dziwnie wykrywa.
    //or ( edit_f.Tag = VK_OEM_7 ) // ~
      or ( edit_f.Tag = VK_OEM_3 ) // ~
    //or (  edit_f.Tag = 192  ) //---// Tyldę dziwnie wykrywa.
    or (  edit_f.Tag = Ord( 'P' )  )
    or (  edit_f.Tag = Ord( 'E' )  )
    or (
             ( Klawisz_Dodatkowy__Miecz_Dobycie_Edit.Tag <> 0  )
         and (
                  ( Klawisz_Dodatkowy__Miecz_Dobycie_Edit.Tag = Klawisz_Dodatkowy__Przeladowanie_Edit.Tag )
               or ( Klawisz_Dodatkowy__Miecz_Dobycie_Edit.Tag = Klawisz_Dodatkowy__Strzal_Edit.Tag )
             )
       )
    or (
             ( Klawisz_Dodatkowy__Przeladowanie_Edit.Tag <> 0  )
         and (
                  ( Klawisz_Dodatkowy__Przeladowanie_Edit.Tag = Klawisz_Dodatkowy__Miecz_Dobycie_Edit.Tag )
               or ( Klawisz_Dodatkowy__Przeladowanie_Edit.Tag = Klawisz_Dodatkowy__Strzal_Edit.Tag )
             )
       ) then
    edit_f.Color := clInfoBk
  else
    edit_f.Color := clDefault;

end;//---//Funkcja Klawisz_Dodatkowy__Nazwa_Ustal().

//Funkcja Dzwieki_Wczytaj().
procedure TStrzelanka_Siekanka_Form.Dzwieki_Wczytaj();
var
  zts : string;
  search_rec : TSearchRec;
begin

  dzwieki__modyfikator_ilosc_g := 0;
  dzwieki__pa_ilosc_g := 0;

  zts := ExtractFilePath( Application.ExeName ) + 'Dźwięki\';


  if FileExists( zts + dzwieki__prefiks__mega_element_c ) then
    try
      Gra_GLSoundLibrary.Samples.AddFile // uses GLFileWAV.
        (
          zts + dzwieki__prefiks__mega_element_c,
          dzwieki__prefiks__mega_element_c
        );
    except
    end;
    //---//try

  if FileExists( zts + dzwieki__prefiks__miecz__lot_c ) then
    try
      Gra_GLSoundLibrary.Samples.AddFile // uses GLFileWAV.
        (
          zts + dzwieki__prefiks__miecz__lot_c,
          dzwieki__prefiks__miecz__lot_c
        );
    except
    end;
    //---//try

  if FileExists( zts + dzwieki__prefiks__pociski_c ) then
    try
      Gra_GLSoundLibrary.Samples.AddFile // uses GLFileWAV.
        (
          zts + dzwieki__prefiks__pociski_c,
          dzwieki__prefiks__pociski_c
        );
    except
    end;
    //---//try

  if FileExists( zts + dzwieki__prefiks__pociski__karabin_maszynowy_c ) then
    try
      Gra_GLSoundLibrary.Samples.AddFile // uses GLFileWAV.
        (
          zts + dzwieki__prefiks__pociski__karabin_maszynowy_c,
          dzwieki__prefiks__pociski__karabin_maszynowy_c
        );
    except
    end;
    //---//try

  if FileExists( zts + dzwieki__prefiks__przeladuj_c ) then
    try
      Gra_GLSoundLibrary.Samples.AddFile // uses GLFileWAV.
        (
          zts + dzwieki__prefiks__przeladuj_c,
          dzwieki__prefiks__przeladuj_c
        );
    except
    end;
    //---//try

  if FileExists( zts + dzwieki__prefiks__przeladowywanie_c ) then
    try
      Gra_GLSoundLibrary.Samples.AddFile // uses GLFileWAV.
        (
          zts + dzwieki__prefiks__przeladowywanie_c,
          dzwieki__prefiks__przeladowywanie_c
        );
    except
    end;
    //---//try

  if FileExists( zts + dzwieki__prefiks__przeladowano_c ) then
    try
      Gra_GLSoundLibrary.Samples.AddFile // uses GLFileWAV.
        (
          zts + dzwieki__prefiks__przeladowano_c,
          dzwieki__prefiks__przeladowano_c
        );
    except
    end;
    //---//try


  // Jeżeli znajdzie plik zwraca 0, jeżeli nie znajdzie zwraca numer błędu. Na początku znajduje '.' '..' potem listę plików.
  if FindFirst(  zts + '*.wav', faAnyFile, search_rec  ) = 0 then // Application potrzebuje w uses Forms.
    begin

      repeat //FindNext( search_rec ) <> 0;
        // Czasami bez begin i end nieprawidłowo rozpoznaje miejsca na umieszczenie breakpoint (linijkę za wysoko) w XE5.


        if Pos( dzwieki__prefiks__modyfikator_c, search_rec.Name ) = 1 then
          begin

            try
              Gra_GLSoundLibrary.Samples.AddFile // uses GLFileWAV.
                (
                  zts + search_rec.Name,
                  dzwieki__prefiks__modyfikator_c + Trim(  FormatFloat( '00', dzwieki__modyfikator_ilosc_g + 1 )  )
                );

              inc( dzwieki__modyfikator_ilosc_g );
            except
            end;
            //---//try


          end
        else//if Pos( dzwieki__modyfikator_ilosc_g, search_rec.Name ) = 1 then
        if Pos( dzwieki__prefiks__pa_c, search_rec.Name ) = 1 then
          begin

            try
              Gra_GLSoundLibrary.Samples.AddFile // uses GLFileWAV.
                (
                  zts + search_rec.Name,
                  dzwieki__prefiks__pa_c + Trim(  FormatFloat( '00', dzwieki__pa_ilosc_g + 1 )  )
                );

              inc( dzwieki__pa_ilosc_g );
            except
            end;
            //---//try


          end;
        //---//if Pos( dzwieki__prefiks__pa_c, search_rec.Name ) = 1 then


      until FindNext( search_rec ) <> 0; // Zwraca dane kolejnego pliku zgodnego z parametrami wcześniej wywołanej funkcji FindFirst. Jeżeli można przejść do następnego znalezionego pliku zwraca 0.

    end;
  //---//if FindFirst(  zts + '*.wav', faAnyFile, search_rec  ) = 0 then


  SysUtils.FindClose( search_rec ); // SysUtils.

end;//---//Funkcja Dzwieki_Wczytaj().

//Funkcja Sekundy_W_Czas_W_Minutach().
function TStrzelanka_Siekanka_Form.Sekundy_W_Czas_W_Minutach( sekundy_f : double ) : string;
var
  minuty : integer;
  znak : string;
begin

  //
  // Funkcja przelicza czas podany w sekundach na wartość w minutach i sekundach.
  //
  // Zwraca czas w minutach i sekundach.
  //
  // Parametry:
  //   sekundy_f
  //

  if sekundy_f < 0 then
    znak := '- '
  else//if sekundy_f < 0 then
    znak := '';

  sekundy_f := Abs( sekundy_f );
  minuty := Round( sekundy_f ) div 60;

  sekundy_f := sekundy_f - minuty * 60;

  Result :=
    znak +
    Trim(  FormatFloat( '### ### ##0', minuty )  ) +
    ':' +
    Trim(  FormatFloat( '00', sekundy_f )  );

end;//---//Funkcja Sekundy_W_Czas_W_Minutach().

//---//      ***      Funkcje      ***      //---//


//FormCreate().
procedure TStrzelanka_Siekanka_Form.FormCreate( Sender: TObject );
begin

  Lewo_GLSphere.Visible := false; // Ma być odkomentowane. //???
  Zero_GLSphere.Visible := false; // Ma być odkomentowane. //???

end;//---//FormCreate().

//FormShow().
procedure TStrzelanka_Siekanka_Form.FormShow( Sender: TObject );
//var
//  zts : string;
begin

  if Self.Tag = 1 then // Ustawienie pełnego ekranu wywołuje FormShow().
    Exit;


  {$region 'Ustawia wartości początkowe (plik ini).'}
  cel__czas_dodania_kolejnego_sekundy__modyfikator_wplyw_g := 0.1;
  cel__czas_dodania_kolejnego_sekundy__poczatkowe_g := 3;
  cel__czas_trwania_sekundy_g := 60;
  cel__dystans_trwania_g := 120;
  cel__ruch_szybkosc__modyfikator_wplyw_g := 0.1;
  cel__ruch_szybkosc__poczatkowe_g := 2;
  karabin_maszynowy__trwanie_sekundy_g := 60;
  magazynek__pojemnosc_g := 12;
  magazynek__przeladowanie__trwanie_sekundy_g := 1.5;
  magazynek__mnoznik__trwanie_sekundy_g := 120;
  mega_element__czas_trwania_sekundy_g := 12000; // 20 minut.
  mega_element__pojawienie_sie_ilosc_g := 100;
  mega_element__poziom__poczatkowe_g := 0;
  mega_element__ulatwienie__czas_dodania_kolejnego_sekundy_g := 60;
  pocisk__czas_trwania_sekundy_g := 60;
  pocisk__dystans_trwania_g := 600;
  pocisk__przeladowanie_trwanie_g := 0.25;
  pocisk__ruch_szybkosc_g := 28;
  {$endregion 'Ustawia wartości początkowe(plik ini).'}

  mega_element__runda_czas__rozpoczecia_g := 0;
  mega_element__runda_czas__zakonczenia_g := 0;

  Gra_GLSceneViewer.Align := alClient;
  //Pomoc_Label.Align := alClient;
  PageControl1.ActivePage := Ustawienia_TabSheet;;
  Opis_Label.Hint := Opis_Label.Caption;
  Ustawienia_ScrollBox.HorzScrollBar.Position := 0;
  Ustawienia_ScrollBox.VertScrollBar.Position := 0;
  Gra_GLSkyDome.Stars.AddRandomStars( 1000, clWhite );

  Randomize();

  Celownicza_Linia_GLLines.Nodes[ 0 ].AsVector := Gra_GLCamera.Position.AsVector;
  //Celownicza_Linia_GLLines.Nodes[ 0 ].AsVector := Zero_GLSphere.Position.AsVector;

  GetOrCreateInertia( Mega_Element_Kontener_GLDummyCube.Behaviours ).Mass := 1;
  GetOrCreateInertia( Mega_Element_Kontener_GLDummyCube.Behaviours ).RotationDamping.SetDamping( 1, 2, 0 ); // Opcjonalne. // Dodatnie jakby spowalnia. // uses GLBehaviours.
  GetOrCreateInertia( Mega_Element_Kontener_GLDummyCube.Behaviours ).TranslationDamping.SetDamping( 1.0, 0, 0.0 ); // Opcjonalne. // Dodatnie wyhamuje, ujemne przyśpiesza. // uses GLBehaviours.

  GetOrCreateInertia( Miecz_Kontener_GLDummyCube.Behaviours ).Mass := 1;
  GetOrCreateInertia( Miecz_Kontener_GLDummyCube.Behaviours ).TranslationDamping.SetDamping( 1.0, 1, 0.0 ); // Opcjonalne. // Dodatnie wyhamuje, ujemne przyśpiesza. // uses GLBehaviours.


  TGLBThorFX(Mega_Element_Efekt_GLDummyCube.AddNewEffect( TGLBThorFX )).Manager := Mega_Element_GLThorFXManager;
  Mega_Element_GLThorFXManager.Wildness := 0; // Ustawienie w inspektorze obiektów nie działa.
  //Mega_Element_GLThorFXManager.GlowSize := 0.75;

  dzwieki__rodzaj_list := TList.Create();
  cele_list := TList.Create();
  pociski_list := TList.Create();

  cel__ostatnio_utworzony_czas_g := Gra_GLCadencer.CurrentTime;
  magazynek__przeladowywanie_w_trakcie := false;

  Statystyki_GLHUDText.TagFloat := Gra_GLCadencer.CurrentTime;

  Miecz__Kolizji_Elementy__Dodaj();

  Gra_GLSceneViewer.SetFocus();

  Self.Tag := 1;

  FormResize( Sender );


  Ustawienia_Plik();

  Dzwieki_Wczytaj();


  Nowa_Gra();

  pocisk__ostatnio_utworzony_czas_g := -pocisk__przeladowanie_trwanie_g;
  magazynek__przeladowanie__rozpoczecie_czas_g := -magazynek__przeladowanie__trwanie_sekundy_g;


  Napis_Odswiez( true );


  Screen.Cursor := crCross;


  {$region '//Sprawdza wczytane dźwięki.'}
  //zts := '';
  //
  //if ActiveSoundManager() = nil then
  //  begin
  //
  //    if zts <> '' then
  //      zts := zts + #13;
  //
  //    zts := zts +
  //      'Nie udało się zainicjować dźwięku.' + #13 +
  //      'Sprawdź dostępność w systemie bibliotek OpenAL (www.openal.org).' + #13 + #13 +
  //      '[Sound failed to initialize.' + #13 +
  //      'Check the availability of OpenAL (www.openal.org) libraries on your system.];
  //
  //  end;
  ////---//if ActiveSoundManager() = nil then
  //
  //if dzwieki__modyfikator_ilosc_g <= 0 then
  //  begin
  //
  //    if zts <> '' then
  //      zts := zts + #13;
  //
  //    zts := zts +
  //     'Brak dźwięków trafień w modyfikatory. [No hit sounds on modifiers.]';
  //
  //  end;
  ////---//if dzwieki__modyfikator_ilosc_g <= 0 then
  //
  //if dzwieki__pa_ilosc_g <= 0 then
  //  begin
  //
  //    if zts <> '' then
  //      zts := zts + #13;
  //
  //    zts := zts +
  //     'Brak dźwięków trafień. [No hit sounds.]';
  //
  //  end;
  ////---//if dzwieki__pa_ilosc_g <= 0 then
  //
  //if Gra_GLSoundLibrary.Samples.GetByName( dzwieki__prefiks__pociski_c ) = nil then
  //  begin
  //
  //    if zts <> '' then
  //      zts := zts + #13;
  //
  //    zts := zts +
  //     'Brak dźwięków pocisków. [No missile sounds.]';
  //
  //  end;
  ////---//if Gra_GLSoundLibrary.Samples.GetByName( dzwieki__prefiks__pociski_c ) = nil then
  //
  //if Gra_GLSoundLibrary.Samples.GetByName( dzwieki__prefiks__pociski__karabin_maszynowy_c ) = nil then
  //  begin
  //
  //    if zts <> '' then
  //      zts := zts + #13;
  //
  //    zts := zts +
  //     'Brak dźwięków pocisków maszynowych. [No machine missile sounds.]';
  //
  //  end;
  ////---//if Gra_GLSoundLibrary.Samples.GetByName( dzwieki__prefiks__pociski__karabin_maszynowy_c ) = nil then
  //
  //if Gra_GLSoundLibrary.Samples.GetByName( dzwieki__prefiks__mega_element_c ) = nil then
  //  begin
  //
  //    if zts <> '' then
  //      zts := zts + #13;
  //
  //    zts := zts +
  //     'Brak dźwięków mega elementu. [No mega element sounds.]';
  //
  //  end
  //else//if Gra_GLSoundLibrary.Samples.GetByName( dzwieki__prefiks__mega_element_c ) = nil then
  //  with TGLBSoundEmitter.Create( Mega_Element_Kontener_GLDummyCube.Behaviours ) do
  //    begin
  //
  //      Source.SoundLibrary := Gra_GLSoundLibrary;
  //      Source.SoundName := dzwieki__prefiks__mega_element_c;
  //      Source.NbLoops := 2; // Wartość większa od 1 zapętla odtwarzanie w nieskończoność.
  //      //Playing := false; // if ActiveSoundManager() <> nil then
  //
  //    end;
  //  //---//with TGLBSoundEmitter.Create( zt_pocisk.Behaviours ) do
  //
  //
  //if zts <> '' then
  //  Application.MessageBox( PChar(zts), 'Informacja', MB_OK + MB_ICONEXCLAMATION );
  {$endregion '//Sprawdza wczytane dźwięki.'}


  if Gra_GLSoundLibrary.Samples.GetByName( dzwieki__prefiks__mega_element_c ) <> nil then
    with TGLBSoundEmitter.Create( Mega_Element_Kontener_GLDummyCube.Behaviours ) do
      begin

        Source.SoundLibrary := Gra_GLSoundLibrary;
        Source.SoundName := dzwieki__prefiks__mega_element_c;
        Source.NbLoops := 2; // Wartość większa od 1 zapętla odtwarzanie w nieskończoność.
        //Playing := false; // if ActiveSoundManager() <> nil then

      end;
    //---//with TGLBSoundEmitter.Create( Mega_Element_Kontener_GLDummyCube.Behaviours ) do

  if Gra_GLSoundLibrary.Samples.GetByName( dzwieki__prefiks__miecz__lot_c ) <> nil then
    with TGLBSoundEmitter.Create( Miecz_Kontener_GLDummyCube.Behaviours ) do
      begin

        Source.SoundLibrary := Gra_GLSoundLibrary;
        Source.SoundName := dzwieki__prefiks__miecz__lot_c;

      end;
    //---//with TGLBSoundEmitter.Create( Miecz_Kontener_GLDummyCube.Behaviours ) do

  if Gra_GLSoundLibrary.Samples.GetByName( dzwieki__prefiks__przeladowano_c ) <> nil then
    with TGLBSoundEmitter.Create( Przeladowania_Dzwieki_Emiter_GLDummyCube.Behaviours ) do
      begin

        Source.SoundLibrary := Gra_GLSoundLibrary;
        Source.SoundName := dzwieki__prefiks__przeladowano_c;

      end;
    //---//with TGLBSoundEmitter.Create( Przeladowania_Dzwieki_Emiter_GLDummyCube.Behaviours ) do

  if Gra_GLSoundLibrary.Samples.GetByName( dzwieki__prefiks__przeladowywanie_c ) <> nil then
    with TGLBSoundEmitter.Create( Przeladowania_Dzwieki_Emiter_GLDummyCube.Behaviours ) do
      begin

        Source.SoundLibrary := Gra_GLSoundLibrary;
        Source.SoundName := dzwieki__prefiks__przeladowywanie_c;
        Source.NbLoops := 2; // Wartość większa od 1 zapętla odtwarzanie w nieskończoność.

      end;
    //---//with TGLBSoundEmitter.Create( Przeladowania_Dzwieki_Emiter_GLDummyCube.Behaviours ) do

  if Gra_GLSoundLibrary.Samples.GetByName( dzwieki__prefiks__przeladuj_c ) <> nil then
    with TGLBSoundEmitter.Create( Przeladowania_Dzwieki_Emiter_GLDummyCube.Behaviours ) do
      begin

        Source.SoundLibrary := Gra_GLSoundLibrary;
        Source.SoundName := dzwieki__prefiks__przeladuj_c;
        Source.NbLoops := 2; // Wartość większa od 1 zapętla odtwarzanie w nieskończoność.

      end;
    //---//with TGLBSoundEmitter.Create( Przeladowania_Dzwieki_Emiter_GLDummyCube.Behaviours ) do



  if ActiveSoundManager() = nil then
    Application.MessageBox
      (
        'Nie udało się zainicjować dźwięku.' + #13 +
        'Sprawdź dostępność w systemie bibliotek OpenAL (www.openal.org).' + #13 + #13 +
        '[Sound failed to initialize.' + #13 +
        'Check the availability of OpenAL (www.openal.org) libraries on your system.]',
        'Informacja', MB_OK + MB_ICONEXCLAMATION
      );


  if not Start_Z_Pauza_CheckBox.Checked then
    Pauza( false );

end;//---//FormShow().

//FormClose().
procedure TStrzelanka_Siekanka_Form.FormClose( Sender: TObject; var CloseAction: TCloseAction );
var
  ztb : boolean;
begin

  ztb := Gra_GLCadencer.Enabled;

  if ztb then
    Pauza( true );

  if Application.MessageBox( 'Czy wyjść z gry?' + #13 + '[Exit the game?]', 'Potwierdzenie', MB_ICONQUESTION + MB_DEFBUTTON2 + MB_YESNO ) <> IDYES then
    begin

      CloseAction := caNone;

      if ztb then
        Pauza( false );

      Exit;

    end;
  //---//if Application.MessageBox( 'Czy wyjść z gry?' + #13 + '[Exit the game?]', 'Potwierdzenie', MB_ICONQUESTION + MB_DEFBUTTON2 + MB_YESNO ) <> IDYES then


  //Pauza( true );

  Miecz__Kolizji_Elementy__Zwolnij_Wszystkie();
  Dzwieki__Rodzaj__Zwolnij_Wszystkie();
  Cele__Zwolnij_Wszystkie();
  Pociski__Zwolnij_Wszystkie();

  FreeAndNil( cele_list );
  FreeAndNil( pociski_list );

end;//---//FormClose().

//FormResize().
procedure TStrzelanka_Siekanka_Form.FormResize( Sender: TObject );
begin

  if not Gra_GLCadencer.Enabled then
    begin

      // Pauza.

      Statystyki_GLHUDSprite.Height := Gra_GLSceneViewer.Height * 2;
      Statystyki_GLHUDSprite.Width := Gra_GLSceneViewer.Width * 2;

      Statystyki_GLHUDSprite.Visible := true;
      Statystyki_GLHUDText.Visible:= Statystyki_GLHUDSprite.Visible;

    end;
  //---//if not Gra_GLCadencer.Enabled then


  Magazynek_GLHUDText.Position.X := Round( Gra_GLSceneViewer.Width * 0.5 );
  Magazynek_GLHUDText.Position.Y := Gra_GLSceneViewer.Height - 25 - 25;
  Magazynek_GLHUDSprite.Position.X := Magazynek_GLHUDText.Position.X;
  Magazynek_GLHUDSprite.Position.Y := Gra_GLSceneViewer.Height - 25;


  Przeladuj_GLHUDText.Position.X := Magazynek_GLHUDText.Position.X;
  Przeladuj_GLHUDText.Position.Y := Round( Gra_GLSceneViewer.Height * 0.5 );

  Przeladuj_GLHUDSprite.Position.X := Przeladuj_GLHUDText.Position.X;
  Przeladuj_GLHUDSprite.Position.Y := Przeladuj_GLHUDText.Position.Y;

  Pomoc_GLHUDSprite.Position.X := Gra_GLSceneViewer.Width - Pomoc_GLHUDSprite.Width * 0.5;
  Pomoc_GLHUDText.Position.X := Pomoc_GLHUDSprite.Position.X + Pomoc_GLHUDSprite.Width * 0.5;


  if Przeladowanie_Klikniecie_Wielkosc_SpinEdit.Value < Przeladowanie_Klikniecie_Wielkosc_SpinEdit.MinValue then
    Przeladowanie_Klikniecie_Wielkosc_SpinEdit.Value := Przeladowanie_Klikniecie_Wielkosc_SpinEdit.MinValue;

  Przeladowanie_Klikniecie_GLHUDSprite.Width := Przeladowanie_Klikniecie_Wielkosc_SpinEdit.Value;
  Przeladowanie_Klikniecie_GLHUDSprite.Height := Przeladowanie_Klikniecie_GLHUDSprite.Width;

  Przeladowanie_Klikniecie_GLHUDSprite.Position.X := Gra_GLSceneViewer.Width - Przeladowanie_Klikniecie_GLHUDSprite.Width * 0.5;
  Przeladowanie_Klikniecie_GLHUDSprite.Position.Y := Gra_GLSceneViewer.Height - Przeladowanie_Klikniecie_GLHUDSprite.Height * 0.5;
  Przeladowanie_Klikniecie_GLHUDText.Position.X := Przeladowanie_Klikniecie_GLHUDSprite.Position.X;
  Przeladowanie_Klikniecie_GLHUDText.Position.Y := Przeladowanie_Klikniecie_GLHUDSprite.Position.Y;


  Miecz_Dobycie_GLHUDSprite.Width := Miecz_Dobycie_Wielkosc_SpinEdit.Value;
  Miecz_Dobycie_GLHUDSprite.Height := Miecz_Dobycie_GLHUDSprite.Width;

  Miecz_Dobycie_GLHUDSprite.Position.X := Miecz_Dobycie_GLHUDSprite.Width * 0.5;
  Miecz_Dobycie_GLHUDSprite.Position.Y := Gra_GLSceneViewer.Height - Miecz_Dobycie_GLHUDSprite.Height * 0.5;
  Miecz_Dobycie_GLHUDText.Position.X := Miecz_Dobycie_GLHUDSprite.Position.X;
  Miecz_Dobycie_GLHUDText.Position.Y := Miecz_Dobycie_GLHUDSprite.Position.Y;

  //Ekran_Margines_Wylicz(); // Przy maksymalizowaniu i przywracaniu normalnego rozmiaru okna nieprawidłowo wylicza wartości.
  Ekran_Margines_Wylicz_Timer.Enabled := true;

end;//---//FormResize().

//Ekran_Margines_Wylicz_TimerTimer().
procedure TStrzelanka_Siekanka_Form.Ekran_Margines_Wylicz_TimerTimer( Sender: TObject );
begin

  // Przełączenie na pełny ekran nie wylicza od razu dobrze wartości.

  Ekran_Margines_Wylicz_Timer.Enabled := false;
  Ekran_Margines_Wylicz_Timer.Tag := 0;

  Ekran_Margines_Wylicz();

end;//---//Ekran_Margines_Wylicz_TimerTimer().

//Pomoc_TimerTimer().
procedure TStrzelanka_Siekanka_Form.Pomoc_TimerTimer( Sender: TObject );
begin

  // Aby podczas pauzy również funkcjonalność działała.

  if    ( Pomoc_GLHUDSprite.Tag = 1 )
    //and ( not PageControl1.Visible )
    and (
              ( not PageControl1.Visible )
           or ( PageControl1.Width < 50 )
         )
    //and ( Gra_GLCadencer.CurrentTime - Pomoc_GLHUDSprite.TagFloat >= 3 ) then
    and (  SecondsBetween( Now(), pomoc_oczekiwanie_rozpoczecie_data_czas ) >= 3  ) then
    begin

      // Po 3 sekundach trzymania kursora w polu pomocy wyświetla panel o programie.

      Pomoc_BitBtnClick( Sender );

      //if Pomoc_Timer.Enabled then
      //  Pomoc_Timer.Enabled := false;

    end;
  //---//if    ( Pomoc_GLHUDSprite.Tag = 1 ) (...)

end;//---//Pomoc_TimerTimer().

//Gra_GLSceneViewerKeyDown().
procedure TStrzelanka_Siekanka_Form.Gra_GLSceneViewerKeyDown( Sender: TObject; var Key: Word; Shift: TShiftState );
//var
//  ztb : boolean;
begin

  if Key = VK_ESCAPE then // uses windows.
    begin

      //ztb := Gra_GLCadencer.Enabled;
      //
      //if ztb then
      //  Pauza( true );
      //
      //if Application.MessageBox( 'Czy wyjść z gry?', 'Potwierdzenie', MB_ICONQUESTION + MB_DEFBUTTON2 + MB_YESNO ) = IDYES then
      //  begin
      //
      //    Close();
      //
      //  end
      //else//if Application.MessageBox( 'Czy wyjść z gry?', 'Potwierdzenie', MB_ICONQUESTION + MB_DEFBUTTON2 + MB_YESNO ) = IDYES then
      //  if ztb then
      //    Pauza( false );

      Close();
      Key := 0;

    end;
  //---//if Key = VK_ESCAPE then


  if Key = VK_F1 then
    begin

      Pomoc_BitBtnClick( Sender );

      Key := 0;

    end;
  //---//if Key = VK_F1 then


  if Key = Ord( 'P' ) then
    begin

      Pauza( nil );
      Key := 0;

    end;
  //---//if Key = Ord( 'P' ) then



  if Key = Ord( 'E' ) then
    begin

      Pelny_Ekran( nil );
      Key := 0;

    end;
  //---//if Key = Ord( 'E' ) then



  if    (  Key = Ord( 'N' )  )
    and ( ssCtrl in Shift ) then
    begin

      //ztb := Gra_GLCadencer.Enabled;
      //
      //if ztb then
      //  Pauza( true );
      //
      //if Application.MessageBox( 'Czy rozpocząć nową grę?', 'Potwierdzenie', MB_ICONQUESTION + MB_DEFBUTTON2 + MB_YESNO ) = IDYES then
      //  begin
      //
      //    Nowa_Gra();
      //
      //    Pauza( false );
      //
      //  end
      //else//if Application.MessageBox( 'Czy rozpocząć nową grę?', 'Potwierdzenie', MB_ICONQUESTION + MB_DEFBUTTON2 + MB_YESNO ) = IDYES then
      //  if ztb then
      //    Pauza( false );

      Nowa_Gra_BitBtnClick( Sender );
      Key := 0;

    end;
  //---//if    (  Key = Ord( 'N' )  ) (...)


  if Gra_GLCadencer.Enabled then
    begin

      if   ( Key = VK_OEM_3 ) // Tyldę dziwnie wykrywa.
        //or ( Key = 192 )
        //or ( Key = VK_OEM_7 ) // ~
        //or (  Key = Ord( '~' )  ) //---// Tyldę dziwnie wykrywa.
        or (
                 ( Klawisz_Dodatkowy__Miecz_Dobycie_Edit.Tag <> 0 )
             and ( Key = Klawisz_Dodatkowy__Miecz_Dobycie_Edit.Tag )
           ) then
        Gra_GLSceneViewerMouseDown( Sender, mbMiddle, Shift, Mouse.CursorPos.X, Mouse.CursorPos.Y );

      if   ( Key = VK_CONTROL )
        or (
                 ( Klawisz_Dodatkowy__Przeladowanie_Edit.Tag <> 0 )
             and ( Key = Klawisz_Dodatkowy__Przeladowanie_Edit.Tag )
           ) then
        Gra_GLSceneViewerMouseDown( Sender, mbRight, Shift, Mouse.CursorPos.X, Mouse.CursorPos.Y );

      if   ( Key = VK_SHIFT )
        or (
                 ( Klawisz_Dodatkowy__Strzal_Edit.Tag <> 0 )
             and ( Key = Klawisz_Dodatkowy__Strzal_Edit.Tag )
           ) then
        Gra_GLSceneViewerMouseDown( Sender, mbLeft, Shift, Mouse.CursorPos.X, Mouse.CursorPos.Y );

    end;
  //---//if Gra_GLCadencer.Enabled then



  if Ukryte_Funkcje_Zezwalaj_CheckBox.Checked then
    begin

      if Key = VK_ADD then
        begin

          Magazynek__Mnoznik_Zmien( 1 );

          Key := 0;

        end;
      //---//if Key = VK_ADD then

      if Key = VK_SUBTRACT then
        begin

          Magazynek__Mnoznik_Zmien( -1 );

          Key := 0;

        end;
      //---//if Key = VK_SUBTRACT then


      if Key = VK_NUMPAD1 then
        begin

          Karabin_Maszynowy_Zmien( true );

          Key := 0;

        end;
      //---//if Key = VK_NUMPAD1 then

      if Key = VK_NUMPAD0 then
        begin

          Karabin_Maszynowy_Zmien( false );

          Key := 0;

        end;
      //---//if Key = VK_NUMPAD0 then


      if Key = VK_NUMPAD7 then
        begin

          Cel__Czas_Dodania_Kolejnego_Zmien( false );

          Key := 0;

        end;
      //---//if Key = VK_NUMPAD7 then

      if Key = VK_NUMPAD9 then
        begin

          Cel__Czas_Dodania_Kolejnego_Zmien( true );

          Key := 0;

        end;
      //---//if Key = VK_NUMPAD9 then


      if Key = VK_NUMPAD8 then
        begin

          Cel__Ruch_Szbkosc_Zmien( false );

          Key := 0;

        end;
      //---//if Key = VK_NUMPAD8 then

      if Key = VK_NUMPAD2 then
        begin

          Cel__Ruch_Szbkosc_Zmien( true );

          Key := 0;

        end;
      //---//if Key = VK_NUMPAD2 then

    end;
  //---//if Ukryte_Funkcje_Zezwalaj_CheckBox.Checked then

end;//---//Gra_GLSceneViewerKeyDown().

//Gra_GLSceneViewerMouseDown().
procedure TStrzelanka_Siekanka_Form.Gra_GLSceneViewerMouseDown( Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer );
var
  mysz_pozycja : TPoint;
  zt_affine_vektor : TAffineVector;
begin

  // Wywołanie Gra_GLSceneViewerMouseDown() nie jest potrzebne jeżeli używane jest IsKeyDown( VK_LBUTTON ) w Gra_GLCadencerProgress().

  if Gra_GLCadencer.Enabled then
    begin

      // Gra.

      mysz_pozycja := ScreenToClient( Mouse.CursorPos );

      if    ( Przeladowanie_Klikniecie_GLHUDSprite.Visible )
        and ( Button = mbLeft )
        and ( mysz_pozycja.x >= Przeladowanie_Klikniecie_GLHUDSprite.Position.X - Przeladowanie_Klikniecie_GLHUDSprite.Width * 0.5 )
        and ( mysz_pozycja.x <= Przeladowanie_Klikniecie_GLHUDSprite.Position.X + Przeladowanie_Klikniecie_GLHUDSprite.Width * 0.5 )
        and ( mysz_pozycja.y >= Przeladowanie_Klikniecie_GLHUDSprite.Position.Y - Przeladowanie_Klikniecie_GLHUDSprite.Height * 0.5 )
        and ( mysz_pozycja.y <= Przeladowanie_Klikniecie_GLHUDSprite.Position.Y + Przeladowanie_Klikniecie_GLHUDSprite.Height * 0.5 ) then
        begin

          // Aby można było przeładowywać na tabletach.

          Button := mbRight;

        end;
      //---//if    ( Przeladowanie_Klikniecie_GLHUDSprite.Visible ) (...)


      if    ( Miecz_Dobycie_GLHUDSprite.Visible )
        and (
                 ( Button = mbLeft )
              or ( Button = mbRight )
            )
        and ( mysz_pozycja.x >= Miecz_Dobycie_GLHUDSprite.Position.X - Miecz_Dobycie_GLHUDSprite.Width * 0.5 )
        and ( mysz_pozycja.x <= Miecz_Dobycie_GLHUDSprite.Position.X + Miecz_Dobycie_GLHUDSprite.Width * 0.5 )
        and ( mysz_pozycja.y >= Miecz_Dobycie_GLHUDSprite.Position.Y - Miecz_Dobycie_GLHUDSprite.Height * 0.5 )
        and ( mysz_pozycja.y <= Miecz_Dobycie_GLHUDSprite.Position.Y + Miecz_Dobycie_GLHUDSprite.Height * 0.5 ) then
        begin

          // Aby można było dobywać miecza na tabletach.

          Button := mbMiddle;

        end;
      //---//if    ( Miecz_Dobycie_GLHUDSprite.Visible ) (...)


      if Button = mbLeft then
        begin

          //mysz_pozycja := ScreenToClient( Mouse.CursorPos );

          zt_affine_vektor := Gra_GLSceneViewer.Buffer.PixelRayToWorld( mysz_pozycja.X, mysz_pozycja.Y );

          Celownicza_Linia_GLLines.Nodes[ 1 ].AsAffineVector := zt_affine_vektor;

          if Gra_GLCadencer.Enabled then
            Pociski__Dodaj_Jeden( zt_affine_vektor );

        end
      else//if Button = mbLeft then
      if Button = mbRight then
        begin

          if magazynek__pociski_ilosc_g < magazynek__pojemnosc_g * magazynek__mnoznik_g * karabin_maszynowy__magazynek__mnoznik_g then
            begin

              magazynek__przeladowanie__rozpoczecie_czas_g := Gra_GLCadencer.CurrentTime;
              magazynek__przeladowywanie_w_trakcie := true;

              Przeladuj_GLHUDText.Text := 'Przeładowywanie (reloading)...';
              Przeladuj_GLHUDSprite.Width := Length( Przeladuj_GLHUDText.Text ) * 20;
              Przeladuj_GLWindowsBitmapFont.EnsureString( Przeladuj_GLHUDText.Text ); // Bez tego nie ma polskich znaków.

              Przeladuj_Komunikat_Ustaw( true );
              Przeladuj_Dzwiek_Ustaw( dzwieki__prefiks__przeladowywanie_c );

              Napis_Odswiez( true );

            end;
          //---//if magazynek__pociski_ilosc_g < magazynek__pojemnosc_g * magazynek__mnoznik_g * karabin_maszynowy__magazynek__mnoznik_g then

        end
      else//if Button = mbRight then
      if Button = mbMiddle then
        begin

          if    ( miecz_dobycie_etap_g in [ mde_Dobyty, mde_Dobywa_Sie ] )
            and ( miecz_chowanie_sie_etap in [ mche_Brak, mche_Gotowy, mche_Ruch_Do_Pozycji ] ) then
            begin

              miecz_dobycie_etap_g := mde_Chowa_Sie;
              miecz_chowanie_sie_etap := mche_Efekty_Neutralizuj;

            end
          else//if    ( miecz_dobycie_etap_g in [ mde_Dobyty, mde_Dobywa_Sie ] ) (...)
          if    ( miecz_dobycie_etap_g in [ mde_Schowany, mde_Chowa_Sie ] )
            and ( miecz_chowanie_sie_etap in [ mche_Brak, mche_Efekty_Neutralizuj, mche_Gotowy, mche_Obrot_Do_Pozycji__Ostrze_W_Gore, mche_Ruch_Do_Pozycji ] ) then
            begin

              if miecz_dobycie_etap_g in [ mde_Schowany ] then
                miecz_chowanie_sie_etap := mche_Ruch_Do_Pozycji
              else//if miecz_dobycie_etap_g in [ mde_Schowany ] then
                if miecz_chowanie_sie_etap in [ mche_Brak, mche_Efekty_Neutralizuj, mche_Obrot_Do_Pozycji__Ostrze_W_Gore, mche_Ruch_Do_Pozycji ] then
                  miecz_chowanie_sie_etap := mche_Brak
                else//if miecz_chowanie_sie_etap in [ mche_Brak, mche_Efekty_Neutralizuj, mche_Obrot_Do_Pozycji__Ostrze_W_Gore, mche_Ruch_Do_Pozycji ] then
                  miecz_chowanie_sie_etap := mche_Ruch_Do_Pozycji;

              miecz_dobycie_etap_g := mde_Dobywa_Sie;

            end;
          //---//if    ( miecz_dobycie_etap_g in [ mde_Schowany, mde_Chowa_Sie ] ) (...)

        end;
      //---//if Button = mbMiddle then

    end;
  //---//if Gra_GLCadencer.Enabled then


  Gra_GLSceneViewer.SetFocus();

end;//---//Gra_GLSceneViewerMouseDown().

//Gra_GLSceneViewerMouseMove().
procedure TStrzelanka_Siekanka_Form.Gra_GLSceneViewerMouseMove( Sender: TObject; Shift: TShiftState; X, Y: Integer );
begin

  if    ( x >= Pomoc_GLHUDSprite.Position.X - Pomoc_GLHUDSprite.Width * 0.5 )
    and ( x <= Pomoc_GLHUDSprite.Position.X + Pomoc_GLHUDSprite.Width * 0.5 )
    and ( y >= Pomoc_GLHUDSprite.Position.Y - Pomoc_GLHUDSprite.Height * 0.5 )
    and ( y <= Pomoc_GLHUDSprite.Position.Y + Pomoc_GLHUDSprite.Height * 0.5 ) then
    begin

      if Pomoc_GLHUDSprite.Tag = 0 then
        begin

          Pomoc_GLHUDSprite.Tag := 1;

          //Pomoc_GLHUDSprite.TagFloat := Gra_GLCadencer.CurrentTime;
          pomoc_oczekiwanie_rozpoczecie_data_czas := Now(); // Aby podczas pauzy również funkcjonalność działała.

          Pomoc_GLHUDSprite.Width := 50;
          Pomoc_GLHUDText.Text := '...?';

          FormResize( Sender );

        end;
      //---//if Pomoc_GLHUDSprite.Tag = 0 then

    end
  else//if    ( x >= Pomoc_GLHUDSprite.Position.X - Pomoc_GLHUDSprite.Width * 0.5 ) (...)
    begin

      Pomoc_GLHUDSprite.Tag := 0;
      Pomoc_GLHUDSprite.Width := 16;
      Pomoc_GLHUDText.Text := '?';

      FormResize( Sender );

    end;
  //---//if    ( x >= Pomoc_GLHUDSprite.Position.X - Pomoc_GLHUDSprite.Width * 0.5 ) (...)

end;//---//Gra_GLSceneViewerMouseMove().

//Gra_GLSceneViewerMouseLeave().
procedure TStrzelanka_Siekanka_Form.Gra_GLSceneViewerMouseLeave( Sender: TObject );
begin

  Gra_GLSceneViewerMouseMove( Sender, [], -1, -1 );

end;//---//Gra_GLSceneViewerMouseLeave().

//Nowa_Gra_BitBtnClick().
procedure TStrzelanka_Siekanka_Form.Nowa_Gra_BitBtnClick( Sender: TObject );
var
  ztb : boolean;
begin

  ztb := Gra_GLCadencer.Enabled;

  if ztb then
    Pauza( true );

  if Application.MessageBox( 'Czy rozpocząć nową grę?' + #13 + '[Start a new game?]', 'Potwierdzenie', MB_ICONQUESTION + MB_DEFBUTTON2 + MB_YESNO ) = IDYES then
    begin

      Nowa_Gra();

      Pauza( false );

    end
  else//if Application.MessageBox( 'Czy rozpocząć nową grę?' + #13 + '[Start a new game?]', 'Potwierdzenie', MB_ICONQUESTION + MB_DEFBUTTON2 + MB_YESNO ) = IDYES then
    if ztb then
      Pauza( false );

end;//---//Nowa_Gra_BitBtnClick().

//Pauza_BitBtnClick().
procedure TStrzelanka_Siekanka_Form.Pauza_BitBtnClick( Sender: TObject );
begin

  Pauza( nil );

end;//---//Pauza_BitBtnClick().

//Pelny_Ekran_BitBtnClick().
procedure TStrzelanka_Siekanka_Form.Pelny_Ekran_BitBtnClick( Sender: TObject );
begin

  Pelny_Ekran( nil );

end;//---//Pelny_Ekran_BitBtnClick().

//Pomoc_BitBtnClick().
procedure TStrzelanka_Siekanka_Form.Pomoc_BitBtnClick( Sender: TObject );
begin

  Pomoc_GLHUDSprite.Tag := 0;

  if    ( PageControl1.Visible )
    and ( PageControl1.Width < 50 ) then
    PageControl1.Width := 300
  else//if    ( PageControl1.Visible ) (...)
    PageControl1.Visible := not PageControl1.Visible;

  if    ( PageControl1.Visible )
    and ( PageControl1.Width < 300 ) then
    PageControl1.Width := 300;

  O_Programie_Splitter.Visible := PageControl1.Visible; //// Działa bez zmieniania Align. // Czasami się gubi.
  O_Programie_Splitter.Align := alLeft;
  O_Programie_Splitter.Align := alRight;

  Napis_Odswiez( true );

  FormResize( Sender );

end;//---//Pomoc_BitBtnClick().

//Glosnosc_SpinEditChange().
procedure TStrzelanka_Siekanka_Form.Glosnosc_SpinEditChange( Sender: TObject );
begin

  if Glosnosc_SpinEdit.Value > Glosnosc_SpinEdit.MaxValue then
    Glosnosc_SpinEdit.Value := Glosnosc_SpinEdit.MaxValue
  else//if zti >= Glosnosc_SpinEdit.MaxValue then
  if Glosnosc_SpinEdit.Value < Glosnosc_SpinEdit.MinValue then
    Glosnosc_SpinEdit.Value := Glosnosc_SpinEdit.MinValue;

  GLSMOpenAL1.MasterVolume := Glosnosc_SpinEdit.Value * 0.01; // Samo powinno dobrze sprawdzać zakres.

end;//---//Glosnosc_SpinEditChange().

//Klawisz_Dodatkowy__EditKeyDown().
procedure TStrzelanka_Siekanka_Form.Klawisz_Dodatkowy__EditKeyDown( Sender: TObject; var Key: Word; Shift: TShiftState );
begin

  if    ( Sender <> nil )
    and ( Sender is TEdit ) then
    begin

      // Del.
      if    ( ssCtrl in Shift )
        and ( Key = VK_DELETE ) then
        Key := 0;

      TEdit(Sender).Tag := Key;

      Key := 0;


      Klawisz_Dodatkowy__Nazwa_Ustal( TEdit(Sender) );

    end;
  //---//if    ( Sender <> nil ) (...)

end;//---//Klawisz_Dodatkowy__EditKeyDown().

//Mega_Element_CheckBoxClick().
procedure TStrzelanka_Siekanka_Form.Mega_Element_CheckBoxClick( Sender: TObject );
begin

  Ekran_Margines_Wylicz();

end;//---//Mega_Element_CheckBoxClick().

//Wyswietlanie_CheckBoxClick().
procedure TStrzelanka_Siekanka_Form.Wyswietlanie_CheckBoxClick( Sender: TObject );
begin

  Magazynek_GLHUDSprite.Visible := Magazynek_Wyswietlaj_CheckBox.Checked;
  Magazynek_GLHUDText.Visible:= Magazynek_GLHUDSprite.Visible;

  Przeladowanie_Klikniecie_GLHUDSprite.Visible := Przeladowanie_Klikniecie_CheckBox.Checked;
  Przeladowanie_Klikniecie_GLHUDText.Visible:= Przeladowanie_Klikniecie_GLHUDSprite.Visible;

  Miecz_Dobycie_GLHUDSprite.Visible := Miecz_Dobycie_CheckBox.Checked;
  Miecz_Dobycie_GLHUDText.Visible:= Miecz_Dobycie_GLHUDSprite.Visible;

  if not Gra_GLCadencer.Enabled then
    Statystyki_GLHUDSprite.Visible := true // Pauza.
  else//if not Gra_GLCadencer.Enabled then
    Statystyki_GLHUDSprite.Visible := Statystyki_Wyswietlaj_CheckBox.Checked; // Gra.

  Statystyki_GLHUDText.Visible:= Statystyki_GLHUDSprite.Visible;

end;//---//Wyswietlanie_CheckBoxClick().

//Ustawienia_Wczytaj_BitBtnClick().
procedure TStrzelanka_Siekanka_Form.Ustawienia_Wczytaj_BitBtnClick( Sender: TObject );
begin

  Ustawienia_Plik();

end;//---//Ustawienia_Wczytaj_BitBtnClick().

//Ustawienia_Zapisz_BitBtnClick().
procedure TStrzelanka_Siekanka_Form.Ustawienia_Zapisz_BitBtnClick( Sender: TObject );
begin

  if Application.MessageBox( 'Czy zapisać ustawienia?' + #13 + '[Save the settings?]', 'Potwierdzenie', MB_YESNO + MB_DEFBUTTON2 + MB_ICONQUESTION ) <> IDYES then
    Exit;

  Ustawienia_Plik( true );

end;//---//Ustawienia_Zapisz_BitBtnClick().

//Gra_GLCadencerProgress().
procedure TStrzelanka_Siekanka_Form.Gra_GLCadencerProgress( Sender: TObject; const deltaTime, newTime: Double );
var
  zti : smallint;
begin

  Cele__Dodaj_Jeden( 0, 0, 0 );

  Cele__Ruch( deltaTime );

  Pociski__Ruch( deltaTime );

  Miecz_Ruch( deltaTime );

  Gra_GLCollisionManager.CheckCollisions();

  Napis_Odswiez();


  if    ( karabin_maszynowy__aktywnosc_g )
    and ( Gra_GLCadencer.CurrentTime - karabin_maszynowy__utworzenie_czas_g > karabin_maszynowy__trwanie_sekundy_g ) then
    Karabin_Maszynowy_Zmien( false );

  if    ( magazynek__mnoznik_g > 1 )
    and ( Gra_GLCadencer.CurrentTime - magazynek__mnoznik__utworzenie_czas_g > magazynek__mnoznik__trwanie_sekundy_g ) then
    Magazynek__Mnoznik_Zmien( -1 );


  // Współczynnik czasu przeładowania magazynka.
  if karabin_maszynowy__aktywnosc_g then
    zti := 4
  else//if karabin_maszynowy__aktywnosc_g then
    zti := 1;

  if    ( magazynek__przeladowywanie_w_trakcie )
    and ( Gra_GLCadencer.CurrentTime - magazynek__przeladowanie__rozpoczecie_czas_g >= magazynek__przeladowanie__trwanie_sekundy_g * zti ) then
    begin

      magazynek__pociski_ilosc_g := magazynek__pojemnosc_g * magazynek__mnoznik_g * karabin_maszynowy__magazynek__mnoznik_g;
      inc( magazynek__przeladowania_ilosc_g );
      magazynek__przeladowywanie_w_trakcie := false;

      Przeladuj_Komunikat_Ustaw( false );
      Przeladuj_Dzwiek_Ustaw( dzwieki__prefiks__przeladowano_c );

      Napis_Odswiez( true );

    end;
  //---//if    ( magazynek__przeladowywanie_w_trakcie ) (...)


  Pomoc_TimerTimer( Sender );


  if    ( Mysz_Ciagle_Strzelanie_CheckBox.Checked )
    and ( not PageControl1.Visible ) // Blokuje działanie przycisków ustawień.
    and (  IsKeyDown( VK_LBUTTON )  ) then // Aby można było strzelać trzymając przycisk myszy.
    Gra_GLSceneViewerMouseDown( Sender, mbLeft, [], 0, 0 ); // Współrzędne myszy nie mają tutaj znaczenia.

end;//---//Gra_GLCadencerProgress().

//Gra_GLCollisionManagerCollision().
procedure TStrzelanka_Siekanka_Form.Gra_GLCollisionManagerCollision( Sender: TObject; object1, object2: TGLBaseSceneObject );
var
  czy_trafienie_mieczem_l : boolean;
  miecz_predkosc_l : real;
  miecz_predkosc_affine_vektor_l : TAffineVector;
  zt_gl_base_scene_object : TGLBaseSceneObject;
begin

  if    ( object1 <> nil )
    and ( object1.Parent <> nil )
    and ( object1.Parent is TCel )
    and ( not TCel(object1.Parent).usunac_cel ) then
    zt_gl_base_scene_object := object1.Parent
  else
  if    ( object1 <> nil )
    and ( object1.Parent <> nil )
    and ( object1.Parent.Parent <> nil )
    and ( object1.Parent.Parent is TCel )
    and ( not TCel(object1.Parent.Parent).usunac_cel ) then
    zt_gl_base_scene_object := object1.Parent.Parent
  else
    zt_gl_base_scene_object := nil;


  if    ( zt_gl_base_scene_object <> nil )
    and ( object2 <> nil )
    and (  not ( object2 is TPocisk )  )
    and (
             (  Pos( miecz_kolizje_elementy_nazwa_prefiks_c, object2.Name ) > 0  )
          //or ( object2.Name = Miecz_Ostrze_GLCylinder.Name ) //???
          //or ( object2.Name = Miecz_Czubek_GLFrustrum.Name )
          //or ( object2.Name = Miecz_GLCube.Name )
          //or ( object2 = Miecz_Ostrze_GLCylinder )
        ) then
    begin

      czy_trafienie_mieczem_l := true;
      miecz_predkosc_affine_vektor_l := GetOrCreateInertia( Miecz_Kontener_GLDummyCube ).TranslationSpeed.AsAffineVector;

      miecz_predkosc_l := Sqr( miecz_predkosc_affine_vektor_l.X ) + Sqr( miecz_predkosc_affine_vektor_l.Y );

      if miecz_predkosc_l > 0 then
        miecz_predkosc_l := Sqrt( miecz_predkosc_l )
      else//if miecz_predkosc_l > 0 then
        miecz_predkosc_l := 0;

    end
  else//if    ( zt_gl_base_scene_object <> nil ) (...)
    czy_trafienie_mieczem_l := false;


  if    ( zt_gl_base_scene_object <> nil )
    and ( object2 <> nil )
    and (
             ( // Aby pocisk nie trafiał kilku celów.
                   ( object2 is TPocisk )
               and ( not TPocisk(object2).usunsc_pocisk )
             )
          or ( czy_trafienie_mieczem_l )
        ) then
    begin


      if    ( czy_trafienie_mieczem_l )
        and ( miecz_predkosc_l < 5 ) then
        begin

          // Jeżeli miecz porusza się zbyt wolno nie przecina celów tylko przesuwa, odbija.
          // Nie dotyczy to składników mega elementu.

          if not TCel(zt_gl_base_scene_object).mega_element_skladnik then
            begin

              if miecz_predkosc_l > 2.5 then
                GetOrCreateInertia( zt_gl_base_scene_object ).ApplyForce
                  (
                    sila_wspolczynnik_staly_c,
                    GLVectorGeometry.VectorScale(  GLVectorGeometry.VectorMake( miecz_predkosc_affine_vektor_l ), 0.05  )
                  )
              else//if miecz_predkosc_l > 2.5 then
                GetOrCreateInertia( zt_gl_base_scene_object ).ApplyForce
                  (
                    sila_wspolczynnik_staly_c,
                    GLVectorGeometry.VectorMake( 0, 1, 0 )
                  );

            end;
          //---//if not TCel(zt_gl_base_scene_object).mega_element_skladnik then

        end
      else//if    ( czy_trafienie_mieczem_l ) (...)
        begin


          // Jeżeli cele zderzą się same ze sobą to się nie rozpadają.

          dec( TCel(zt_gl_base_scene_object).rozmiar_poziomy );


          if TCel(zt_gl_base_scene_object).modyfikator_rodzaj = mr_Cele_Czesciej then
            Cel__Czas_Dodania_Kolejnego_Zmien( false )
          else
          if TCel(zt_gl_base_scene_object).modyfikator_rodzaj = mr_Cele_Rzadziej then
            Cel__Czas_Dodania_Kolejnego_Zmien( true )
          else
          if TCel(zt_gl_base_scene_object).modyfikator_rodzaj = mr_Cele_Szybciej then
            Cel__Ruch_Szbkosc_Zmien( true )
          else
          if TCel(zt_gl_base_scene_object).modyfikator_rodzaj = mr_Cele_Wolniej then
            Cel__Ruch_Szbkosc_Zmien( false )
          else
          if TCel(zt_gl_base_scene_object).modyfikator_rodzaj = mr_Karabin_Maszynowy then
            Karabin_Maszynowy_Zmien( true )
          else
          if TCel(zt_gl_base_scene_object).modyfikator_rodzaj = mr_Magazynek_Wiekszy then
            Magazynek__Mnoznik_Zmien( 1 )
          else
            if mega_element__etap_g = mee_Brak then
              begin

                if Mega_Element_CheckBox.Checked then
                  inc( mega_element__trafienia_licznik_g );

                Mega_Element_Efekt_Wylicz();

              end;
            //---//if mega_element__etap_g = mee_Brak then


          if not czy_trafienie_mieczem_l then
             begin

               TPocisk(object2).usunsc_pocisk := true;
               inc( trafienia_ilosc_g );

             end
           else//if not czy_trafienie_mieczem_l then
             begin

               TCel(zt_gl_base_scene_object).trafienie_mieczem := true;
               TCel(zt_gl_base_scene_object).miecz_predkosc_affine_vektor := miecz_predkosc_affine_vektor_l;
               inc( trafienia_ilosc_miecz_g );

             end;
           //---//if not czy_trafienie_mieczem_l then


          TCel(zt_gl_base_scene_object).usunac_cel := true;

        end;
      //---//if    ( czy_trafienie_mieczem_l ) (...)

    end;
  //---//if    ( object1 <> nil ) (...)

end;//---//Gra_GLCollisionManagerCollision().

end.
