{
  LaKraven Studios Standard Library [LKSL]
  Copyright (c) 2014-2015, LaKraven Studios Ltd, All Rights Reserved

  Original Source Location: https://github.com/LaKraven/LKSL

  License:
    - You may use this library as you see fit, including use within commercial applications.
    - You may modify this library to suit your needs, without the requirement of distributing
      modified versions.
    - You may redistribute this library (in part or whole) individually, or as part of any
      other works.
    - You must NOT charge a fee for the distribution of this library (compiled or in its
      source form). It MUST be distributed freely.
    - This license and the surrounding comment block MUST remain in place on all copies and
      modified versions of this source code.
    - Modified versions of this source MUST be clearly marked, including the name of the
      person(s) and/or organization(s) responsible for the changes, and a SEPARATE "changelog"
      detailing all additions/deletions/modifications made.

  Disclaimer:
    - Your use of this source constitutes your understanding and acceptance of this
      disclaimer.
    - LaKraven Studios Ltd and its employees (including but not limited to directors,
      programmers and clerical staff) cannot be held liable for your use of this source
      code. This includes any losses and/or damages resulting from your use of this source
      code, be they physical, financial, or psychological.
    - There is no warranty or guarantee (implicit or otherwise) provided with this source
      code. It is provided on an "AS-IS" basis.

  Donations:
    - While not mandatory, contributions are always appreciated. They help keep the coffee
      flowing during the long hours invested in this and all other Open Source projects we
      produce.
    - Donations can be made via PayPal to PayPal [at] LaKraven (dot) Com
                                          ^  Garbled to prevent spam!  ^
}
unit LKSL.Generics.Collections;

interface

{$I LKSL.inc}

{$IFDEF FPC}
  {$IFDEF LKSL_MODE_FPC}
    {$mode objfpc}{$H+}
  {$ELSE}
    {$mode delphi}
  {$ENDIF LKSL_MODE_FPC}
{$ENDIF FPC}

{
  About this unit:
    - This unit provides useful enhancements for Generics types used in the LKSL.
}

uses
  {$IFDEF LKSL_USE_EXPLICIT_UNIT_NAMES}
    System.Classes, System.SysUtils, System.SyncObjs,
  {$ELSE}
    Classes, SysUtils, SyncObjs,
  {$ENDIF LKSL_USE_EXPLICIT_UNIT_NAMES}
  {$IFNDEF FPC}
    Generics.Defaults,
    Generics.Collections,
  {$ELSE}
    fgl,
  {$ENDIF FPC}
  LKSL.Common.Types,
  LKSL.Generics.Defaults;

  {$I LKSL_RTTI.inc}

type
  { Forward Declaration }
  {$IFDEF FPC}
    TArray<T> = Array of T;
  {$ELSE}
    TLKSortHandler<T> = class;
    TLKArray<T> = class;
    TLKDictionary<TKey, TValue> = class;
//    TLKHashMap<TKey, TValue> = class;
    TLKListBase<T> = class;
    TLKList<T> = class;
    TLKObjectList<T: class> = class;
    TLKSortedListBase<T> = class;
    TLKSortedList<T> = class;
    TLKSortedObjectList<T: class> = class;
    TLKCenteredList<T> = class;
    TLKCenteredObjectList<T: class> = class;
    TLKTreeNode<T> = class;
    TLKTreeObjectNode<T: class> = class;
  {$ENDIF FPC}

  { Enum Types }
  TLKListDirection = (ldLeft, ldRight);
  TLKListSortOrder = (soAscending, soDescending);
  TLKListFinalizeMode = (fmNoFinalize, fmFinalize);
  TLKListSmartCompactMode = (scmNoSmartCompact, scmSmartCompact);

  { Exception Types }
  ELKGenericCollectionsException = class(ELKException);
    ELKGenericCollectionsLimitException = class(ELKGenericCollectionsException);
    ELKGenericCollectionsRangeException = class(ELKGenericCollectionsException);
    ELKGenericCollectionsKeyAlreadyExists = class(ELKGenericCollectionsException);
    ELKGenericCollectionsKeyNotFound = class(ELKGenericCollectionsException);

  {
    TLKSortHandler<T>
      - Used to dictate how to determine the order of Items in a List/Array when Sorting it.
      - Allows you to provide Dynamic Sorting Behaviour at Runtime!
  }
  TLKSortHandler<T> = class abstract(TLKPersistent)
  public
    // Parity Checks
    function AEqualToB(const A, B: T): Boolean; virtual; abstract;
    function AGreaterThanB(const A, B: T): Boolean; virtual; abstract;
    function AGreaterThanOrEqualB(const A, B: T): Boolean; virtual; abstract;
    function ALessThanB(const A, B: T): Boolean; virtual; abstract;
    function ALessThanOrEqualB(const A, B: T): Boolean; virtual; abstract;
  end;

  {
    TLKArray<T>
      - Provides a Thread-Safe Lock (TCriticalSection)
      - A very simple "Managed Array" for items of the nominated type.
      - Items are UNSORTED
      - The Array expands by 1 each time a new item is added
      - The Array collapses by 1 each time an item is removed
      - If referencing the "ArrayRaw" property, don't forget to call "Lock" and "Unlock" manually!
  }
  TLKArray<T> = class(TLKPersistent)
  type
    TLKArrayType = Array of T;
  private
    FArray: TLKArrayType;
    FLock: TCriticalSection;

    // Getters
    function GetItem(const AIndex: Integer): T;

    // Setters
    procedure SetItem(const AIndex: Integer; const AItem: T);
  public
    constructor Create; override;
    destructor Destroy; override;

    procedure Lock; inline;
    procedure Unlock; inline;

    function Add(const AItem: T): Integer;
    procedure Clear; inline;
    procedure Delete(const AIndex: Integer); virtual;

    property ArrayRaw: TLKArrayType read FArray;
    property Items[const AIndex: Integer]: T read GetItem write SetItem;
  end;

  {
    TLKDictionary<TKey, TValue>
      - Provides a Thread-Safe Lock (TCriticalSection)
  }
  TLKDictionary<TKey, TValue> = class({$IFDEF FPC}TFPGMap{$ELSE}TDictionary{$ENDIF FPC}<TKey, TValue>)
    private
      FLock: TCriticalSection;
    public
      {$IFDEF FPC}
        constructor Create; reintroduce;
      {$ELSE}
        constructor Create(ACapacity: Integer = 0); reintroduce; overload;
        constructor Create(const AComparer: IEqualityComparer<TKey>); reintroduce; overload;
        constructor Create(ACapacity: Integer; const AComparer: IEqualityComparer<TKey>); reintroduce; overload;
        constructor Create(const Collection: TEnumerable<TPair<TKey,TValue>>); reintroduce; overload;
        constructor Create(const Collection: TEnumerable<TPair<TKey,TValue>>; const AComparer: IEqualityComparer<TKey>); reintroduce; overload;
      {$ENDIF FPC}
      destructor Destroy; override;

      {$IFDEF FPC}
        function TryGetValue(const AKey: TKey; var AValue: TValue): Boolean;
        function ContainsKey(const AKey: TKey): Boolean;
      {$ENDIF FPC}

      procedure Lock; inline;
      procedure Unlock; inline;
    end;

  ///  <summary><c>Thread-safe Hashed Key/Value Map.</c></summary>
  ///  <remarks><c>Note that this is not ready for use at this time!</c></remarks>
{  TLKHashMap<TKey, TValue> = class(TLKPersistent)
  private type
    TItem = record
      HashCode: Integer;
      Key: TKey;
      Value: TValue;
    end;
    TItemArray = Array of TItem;
  private
    FItems: TItemArray;
    FCapacityMultiplier: Single;
    FCapacityThreshold: Integer;
    FCount: Integer;
    FLock: TCriticalSection;

    function Hash(const AKey: TKey): Integer;
  end;}

  {
    TLKListBase<T>
      - Abstract Base Type for TLKList[variation]<T> types
  }
  TLKListBase<T> = class abstract(TLKPersistent)
  private
    type
      TArrayOfT = Array of T;
      {$IFDEF SUPPORTS_REFERENCETOMETHOD}
        TIterateCallbackAnon = reference to procedure(const AIndex: Integer; const AItem: T);
      {$ENDIF SUPPORTS_REFERENCETOMETHOD}
      TIterateCallbackOfObject = procedure(const AIndex: Integer; const AItem: T) of object;
      TIterateCallbackUnbound = procedure(const AIndex: Integer; const AItem: T);
      TLKSortHandlerT = class(TLKSortHandler<T>);
  private
    FArray: TArrayOfT;
    FCapacityMultiplier: Single;
    FCapacityThreshold: Integer;
    {$IFNDEF FPC}
      FComparer: IComparer<T>;
    {$ENDIF FPC}
    FCount: Integer;
    // Getters - Capacity
    function GetCapacity: Integer;
    function GetCapacityMultiplier: Single;
    function GetCapacityThreshold: Integer;
    // Getters - Other
    function GetCount: Integer;
    function GetIsEmpty: Boolean;
    function GetItemByIndex(const AIndex: Integer): T;

    // Setters - Capacity
    procedure SetCapacityMultiplier(const AMultiplier: Single);
    procedure SetCapacityThreshold(const AThreshold: Integer);

    procedure InitializeArray;
  protected
    // Add
    function AddActual(const AItem: T): Integer; virtual;
    // Remove
    function RemoveActual(const AItem: T): Integer;
    // Capacity Management
    procedure CheckCapacity; overload; inline;
    procedure CheckCapacity(const ATotalRequiredCapacity: Integer); overload;
    // Array Management
    procedure Finalize(const AIndex, ACount: Integer);
    procedure Move(const AFromIndex, AToIndex, ACount: Integer);
    // Delete
    procedure DeleteActual(const AIndex: Integer; const AFinalizeMode: TLKListFinalizeMode; const ASmartCompactMode: TLKListSmartCompactMode);
    // Insert
    procedure InsertActual(const AItem: T; const AIndex: Integer); inline;
    // Quick Sort
    procedure QuickSort(const ASortHandler: TLKSortHandlerT; ALow, AHigh: Integer; const ASortOrder: TLKListSortOrder = soAscending);
    // Smart Compact
    procedure CompactActual;
    procedure SmartCompact;
    // Validation Methods
    function ValidateIndexInRange(const AIndex: Integer): Boolean;
    function ValidateRangeInArray(const AFrom, ATo: Integer): Boolean;
  public
    constructor Create; overload; override;
    {$IFNDEF FPC}
      constructor Create(const AComparer: IComparer<T>); reintroduce; overload; virtual;
    {$ENDIF FPC}
    destructor Destroy; override;

    function Add(const AItem: T): Integer; overload; virtual;
    procedure Add(const AItems: TArrayOfT); overload;

    procedure Clear(const ACompact: Boolean = True); virtual;
    procedure Compact; inline;

    ///  <summary><c>Delete a specific Item at the given Index.</c></summary>
    procedure Delete(const AIndex: Integer); overload; virtual;
    ///  <summary><c>Alias of </c>DeleteRange</summary>
    procedure Delete(const AFirstIndex, ACount: Integer); overload; inline;
    ///  <summary><c>Delete a Range of Items from the given Index.</c></summary>
    procedure DeleteRange(const AIndex, ACount: Integer); virtual;

    function Remove(const AItem: T): Integer; overload; inline;
    procedure Remove(const AItems: TArrayOfT); overload;

    {$IFDEF SUPPORTS_REFERENCETOMETHOD}
      procedure Iterate(const AIterateCallback: TIterateCallbackAnon; const AIterateDirection: TLKListDirection = ldRight); overload;
      procedure Iterate(const AIterateCallback: TIterateCallbackAnon; const AFrom, ATo: Integer); overload;
    {$ENDIF SUPPORTS_REFERENCETOMETHOD}
    procedure Iterate(const AIterateCallback: TIterateCallbackOfObject; const AIterateDirection: TLKListDirection = ldRight); overload;
    procedure Iterate(const AIterateCallback: TIterateCallbackOfObject; const AFrom, ATo: Integer); overload;
    procedure Iterate(const AIterateCallback: TIterateCallbackUnbound; const AIterateDirection: TLKListDirection = ldRight); overload;
    procedure Iterate(const AIterateCallback: TIterateCallbackUnbound; const AFrom, ATo: Integer); overload;

    function Contains(const AItem: T): Boolean; overload; inline;
    function Contains(const AItems: TArrayOfT): Boolean; overload;
    function IndexOf(const AItem: T): Integer;

    procedure Sort(const ASortHandler: TLKSortHandlerT; const ASortOrder: TLKListSortOrder = soAscending);

    ///  <summary><c>The number of Slots presently allocated for the List.</c></summary>
    ///  <remarks><c>Read-Only</c></remarks>
    property Capacity: Integer read GetCapacity;
    ///  <summary><c>By what Factor to increase the Size of the List when the Capacity Threshold is reached.</c></summary>
    property CapacityMultiplier: Single read GetCapacityMultiplier write SetCapacityMultiplier;
    ///  <summary><c>The Minimum number of Vacant Slots in the List before the List is Expanded.</c></summary>
    property CapacityThreshold: Integer read GetCapacityThreshold write SetCapacityThreshold;
    ///  <summary><c>The number of Items presently occupying the List.</c></summary>
    ///  <remarks><c>Read-Only</c></remarks>
    property Count: Integer read GetCount;
    ///  <summary><c>Returns </c>True<c> if the List contains no Items.</c></summary>
    property IsEmpty: Boolean read GetIsEmpty;
    ///  <summary><c>Retrieves the Item at the given Index</c></summary>
    property Items[const AIndex: Integer]: T read GetItemByIndex; default;
  end;

  {
    TLKList<T>
      - A simple Generic List Type (light-weight)
  }
  TLKList<T> = class(TLKListBase<T>)
  public
    procedure Insert(const AItem: T; const AIndex: Integer);
  end;

  {
    TLKObjectList<T: class>
      - A version of TLKList<T> capable of handling ownership of Class Instances
  }
  TLKObjectList<T: class> = class(TLKList<T>)
  private
    FOwnsObjects: Boolean;
    function GetOwnsObjects: Boolean;
    procedure SetOwnsObjects(const AOwnsObjects: Boolean);
  public
    constructor Create(const AOwnsObjects: Boolean = True); overload;
    {$IFNDEF FPC}
      constructor Create(const AComparer: IComparer<T>; const AOwnsObjects: Boolean = True); overload;
    {$ENDIF FPC}
    destructor Destroy; override;

    procedure Clear(const ACompact: Boolean = True); override;
    procedure Delete(const AIndex: Integer); override;

    property OwnsObjects: Boolean read GetOwnsObjects write SetOwnsObjects;
  end;

  {
    TLKSortedListBase<T>
      - A TLKListBase<T> with Sorted Insertion
      - Abstract methods need to be implemented on type-specific descendants
  }
  TLKSortedListBase<T> = class abstract(TLKListBase<T>)
  protected
    // Parity Checks
    function AEqualToB(const A, B: T): Boolean; virtual; abstract;
    function AGreaterThanB(const A, B: T): Boolean; virtual; abstract;
    function AGreaterThanOrEqualB(const A, B: T): Boolean; virtual; abstract;
    function ALessThanB(const A, B: T): Boolean; virtual; abstract;
    function ALessThanOrEqualB(const A, B: T): Boolean; virtual; abstract;
    // Critical Utility Methods
    function GetSortedPosition(const AItem: T): Integer;
  end;

  {
    TLKSortedList<T>
      - An implementation of TLKSortedListBase<T> supporting Duplicate Sorted Keys
      - Abstract methods need to be implemented on type-specific descendants
  }
  TLKSortedList<T> = class abstract(TLKSortedListBase<T>)
  protected
    function AddActual(const AItem: T): Integer; override;
  end;

  {
    TLKSortedObjectList<T: class; TKey>
      - A version of TLKSortedList<T> capable of handling ownership of Class Instances
      - Abstract methods need to be implemented on type-specific descendants
  }
  TLKSortedObjectList<T: class> = class abstract(TLKSortedListBase<T>)
  private
    FOwnsObjects: Boolean;
    function GetOwnsObjects: Boolean;
    procedure SetOwnsObjects(const AOwnsObjects: Boolean);
  public
    constructor Create(const AOwnsObjects: Boolean = True); reintroduce; overload;
    {$IFNDEF FPC}
      constructor Create(const AComparer: IComparer<T>; const AOwnsObjects: Boolean = True); reintroduce; overload;
    {$ENDIF FPC}
    destructor Destroy; override;

    procedure Clear(const ACompact: Boolean = True); override;
    procedure Delete(const AIndex: Integer); override;

    property OwnsObjects: Boolean read GetOwnsObjects write SetOwnsObjects;
  end;

{$IFNDEF FPC}
  {
    TLKCenteredList
      - A special Generic List object which allows the use of both positive and NEGATIVE indices!
      - Essentially, we're cheating: using two Arrays (and a singular instance to represent index 0)
        - Any LEFT (negative) assignment goes on the end of the LEFT Array, any RIGHT (positive)
          assignment goes on the end of the RIGHT Array.
        - In a sense, this means you have a combined Queue AND Stack acting like a singular Array.
      - NOT RELATED TO TLKListBase<T> IN ANY WAY! ENTIRELY DISTINCT IMPLEMENTATION!
  }
  TLKCenteredList<T> = class(TPersistent)
  private
    type
      TArrayOfT = Array of T;
  private
    // Counts
    FCountLeft: Integer;
    FCountRight: Integer;
    // Locks
    FLockCenter: TCriticalSection;
    FLockLeft: TCriticalSection;
    FLockRight: TCriticalSection;
    // Arrays (and Center)
    FArrayLeft: TArrayOfT;
    FArrayRight: TArrayOfT;
    FCenter: T;
    // Capacity
    FCapacityMultiplier: Single;
    FCapacityThreshold: Integer;
    // Necessary Other Stuff
    FCenterAssigned: Boolean;

    // Capacity Checks
    procedure CheckCapacityLeft;
    procedure CheckCapacityRight;
    // Capacity Getters
    function GetCapacity: Integer; // GetCapacityLeft + GetCapacityRight + 1
    function GetCapacityLeft: Integer; // Size of FArrayLeft
    function GetCapacityRight: Integer; // Size of FArrayRight
    function GetCapacityMultiplier: Single;
    function GetCapacityThreshold: Integer;
    // Count Getters
    function GetCount: Integer; // GetCountLeft + GetCountRight + FCenterAssigned
    function GetCountLeft: Integer; // Number of Items in FArrayLeft
    function GetCountRight: Integer; // Number of Items in FArrayRight
    // Item Getters
    function GetItemByIndex(const AIndex: Integer): T;
    function GetItemCenter: T;
    function GetItemLeft(const AIndex: Integer): T;
    function GetItemRight(const AIndex: Integer): T;
    // Range Getters
    function GetRangeLow: Integer;
    function GetRangeHigh: Integer;
    // Insert Methods
    procedure InsertCenter(const AItem: T; const AShiftDirection: TLKListDirection = ldRight);
    procedure InsertLeft(const AItem: T; const AIndex: Integer; const AShiftDirection: TLKListDirection = ldRight);
    procedure InsertRight(const AItem: T; const AIndex: Integer; const AShiftDirection: TLKListDirection = ldRight);
    // General
    function TryCenterAvailable(const AItem: T): Boolean;

    // Capacity Setters
    procedure SetCapacityMultiplier(const AMultiplier: Single);
    procedure SetCapacityThreshold(const AThreshold: Integer);
    // Item Setters
    procedure SetItemByIndex(const AIndex: Integer; const AItem: T);
    procedure SetItemCenter(const AItem: T);
    procedure SetItemLeft(const AIndex: Integer; const AItem: T);
    procedure SetItemRight(const AIndex: Integer; const AItem: T);
  protected
    // Deletes
    procedure DeleteCenter; virtual;
    procedure DeleteLeft(const AIndex: Integer); virtual;
    procedure DeleteRight(const AIndex: Integer); virtual;
    // Array Management
    procedure Finalize(var AArray: TArrayOfT; const AIndex, ACount: Integer);
    procedure Move(var AArray: TArrayOfT; const AFromIndex, AToIndex, ACount: Integer);
    // Validations
    function ValidateDeleteCenter: Boolean;
    function ValidateDeleteLeft(const AIndex: Integer): Boolean;
    function ValidateDeleteRight(const AIndex: Integer): Boolean;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    function Add(const AItem: T; const ADirection: TLKListDirection = ldRight): Integer; overload; virtual;
    procedure Add(const AItems: TArrayOfT; const ADirection: TLKListDirection = ldRight); overload; virtual;
    function AddLeft(const AItem: T): Integer; overload; virtual;
    procedure AddLeft(const AItems: TArrayOfT); overload;
    function AddRight(const AItem: T): Integer; overload; virtual;
    procedure AddRight(const AItems: TArrayOfT); overload;


    procedure Compact;

    procedure Delete(const AIndex: Integer); overload; virtual;
    procedure Delete(const AIndices: Array of Integer); overload; virtual;
    procedure DeleteRange(const ALow, AHigh: Integer); virtual;

    procedure Insert(const AItem: T; const AIndex: Integer; const AShiftDirection: TLKListDirection = ldRight);

    procedure Lock; inline;
    procedure LockCenter; inline;
    procedure LockLeft; inline;
    procedure LockRight; inline;

    procedure Unlock; inline;
    procedure UnlockCenter; inline;
    procedure UnlockLeft; inline;
    procedure UnlockRight; inline;

    procedure Swap(const AFrom, ATo: Integer);

    // Capacity Properties
    property Capacity: Integer read GetCapacity;
    property CapacityLeft: Integer read GetCapacityLeft;
    property CapacityRight: Integer read GetCapacityRight;
    property CapacityMultiplier: Single read GetCapacityMultiplier write SetCapacityMultiplier;
    property CapacityThreshold: Integer read GetCapacityThreshold write SetCapacityThreshold;
    // Count Properties
    property Count: Integer read GetCount;
    property CountLeft: Integer read GetCountLeft;
    property CountRight: Integer read GetCountRight;
    // Item Properties
    property Items[const AIndex: Integer]: T read GetItemByIndex write SetItemByIndex; default;
    // Range Properties
    property Low: Integer read GetRangeLow;
    property High: Integer read GetRangeHigh;
  end;

  {
    TLKCenteredObjectList<T: class>
      - A special version of TLKCenteredList<T> for Objects
      - Has the ability to OWN its Items (so they are destroyed with the List)
  }
  TLKCenteredObjectList<T: class> = class(TLKCenteredList<T>)
  private
    FOwnsObjects: Boolean;
  protected
    // Deletes
    procedure DeleteCenter; override;
    procedure DeleteLeft(const AIndex: Integer); override;
    procedure DeleteRight(const AIndex: Integer); override;
  public
    constructor Create(const AOwnsObjects: Boolean = True); reintroduce;

    property OwnsObjects: Boolean read FOwnsObjects write FOwnsObjects;
  end;

  {
    TLKTreeNode<T>
      - A special Generic Tree Object with thread-safe Locks
      - Acts as both the Root and Child node (dependant on whether or not it contains a Parent)
  }
  TLKTreeNode<T> = class(TLKObject)
  private type
    {$IFDEF SUPPORTS_REFERENCETOMETHOD}
      TLKValueCallback<V> = reference to procedure(const Value: V);
    {$ELSE}
      TLKValueCallback<V> = procedure(const Value: V);
    {$ENDIF SUPPORTS_REFERENCETOMETHOD}
  private
    FParent: TLKTreeNode<T>;
    FChildren: TLKObjectList<TLKTreeNode<T>>;
    FValue: T;

    FDestroying: Boolean;

    procedure DoAncestorChanged;

    function GetRootNode: TLKTreeNode<T>;
    function GetChildCount: Integer; inline;
    function GetChildren(const AIndex: Integer): TLKTreeNode<T>; inline;
    function GetIndexAsChild: Integer; inline;

    function GetIsBranch: Boolean; inline;
    function GetIsRoot: Boolean; inline;
    function GetIsLeaf: Boolean; inline;
    function GetDepth: Integer;
  protected
    procedure AncestorChanged; virtual;
    procedure Destroying; virtual;

    procedure AddChild(const AIndex: Integer; const AChild: TLKTreeNode<T>); virtual;
    procedure RemoveChild(const AChild: TLKTreeNode<T>); virtual;

    procedure SetValue(const AValue: T); virtual;

    property IsDestroying: Boolean read FDestroying;
  public
    constructor Create(const AParent: TLKTreeNode<T>; const AValue: T); reintroduce; overload;
    constructor Create(const AParent: TLKTreeNode<T>); reintroduce; overload;
    constructor Create(const AValue: T); reintroduce; overload;
    constructor Create; overload; override;
    destructor Destroy; override;

    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;

    procedure MoveTo(const ANewParent: TLKTreeNode<T>; const AIndex: Integer = -1); overload;
    procedure MoveTo(const AIndex: Integer); overload; inline;

    function IndexOf(const AChild: TLKTreeNode<T>): Integer; inline;

    procedure PreOrderWalk(const AAction: TLKValueCallback<TLKTreeNode<T>>); overload;
    procedure PreOrderWalk(const AAction: TLKValueCallback<T>); overload;

    procedure PostOrderWalk(const AAction: TLKValueCallback<TLKTreeNode<T>>); overload;
    procedure PostOrderWalk(const AAction: TLKValueCallback<T>); overload;

    property Depth: Integer read GetDepth;

    property Parent: TLKTreeNode<T> read FParent;
    property RootNode: TLKTreeNode<T> read GetRootNode;
    property ChildCount: Integer read GetChildCount;
    property Children[const AIndex: Integer]: TLKTreeNode<T> read GetChildren; default;
    property IndexAsChild: Integer read GetIndexAsChild;

    property IsBranch: Boolean read GetIsBranch;
    property IsRoot: Boolean read GetIsRoot;
    property IsLeaf: Boolean read GetIsLeaf;

    property Value: T read FValue write SetValue;
  end;

  {
    TLKTreeObjectNode<T: class>
      - Special variant of TLKTreeNode<T> for Objects
      - Has the ability to OWN its Values (so they are destroyed with the Node)
  }
  TLKTreeObjectNode<T: class> = class(TLKTreeNode<T>)
  private
    FOwnsObject: Boolean;
  public
    constructor Create(const AParent: TLKTreeNode<T>; const AValue: T); reintroduce; overload;
    constructor Create(const AParent: TLKTreeNode<T>); reintroduce; overload;
    constructor Create(const AValue: T); reintroduce; overload;
    constructor Create; reintroduce; overload;
    destructor Destroy; override;

    property OwnsObject: Boolean read FOwnsObject write FOwnsObject;
  end;
{$ENDIF FPC}

const
  LKSL_LIST_CAPACITY_DEFAULT = 10;
  LKSL_LIST_MULTIPLIER_MINIMUM = 1.10;
  LKSL_LIST_MULTIPLIER_MAXIMUM = 3.00;
  LKSL_LIST_MULTIPLIER_DEFAULT = 1.5;
  LKSL_LIST_THRESHOLD_MINIMUM = 5;
  LKSL_LIST_THRESHOLD_DEFAULT = LKSL_LIST_THRESHOLD_MINIMUM;

implementation

{ TLKArray<T> }

function TLKArray<T>.Add(const AItem: T): Integer;
begin
  Result := Length(FArray);
  SetLength(FArray, Result + 1);
  FArray[Result] := AItem;
end;

procedure TLKArray<T>.Clear;
begin
  SetLength(FArray, 0);
end;

constructor TLKArray<T>.Create;
begin
  inherited;
  FLock := TCriticalSection.Create;
end;

procedure TLKArray<T>.Delete(const AIndex: Integer);
var
  I: Integer;
begin
  Lock;
  try
    for I := AIndex to Length(FArray) - 2 do
      FArray[I] := FArray[I + 1];

    SetLength(FArray, Length(FArray) - 1);
  finally
    Unlock;
  end;
end;

destructor TLKArray<T>.Destroy;
begin
  FLock.Free;
  inherited;
end;

function TLKArray<T>.GetItem(const AIndex: Integer): T;
begin
  Lock;
  try
    Result := FArray[AIndex];
  finally
    Unlock;
  end;
end;

procedure TLKArray<T>.Lock;
begin
  FLock.Acquire;
end;

procedure TLKArray<T>.SetItem(const AIndex: Integer; const AItem: T);
begin
  Lock;
  try
    FArray[AIndex] := AItem;
  finally
    Unlock;
  end;
end;

procedure TLKArray<T>.Unlock;
begin
  FLock.Release;
end;

{ TLKDictionary<TKey, TValue> }

{$IFDEF FPC}
  constructor TLKDictionary<TKey, TValue>.Create;
  begin
    FLock := TCriticalSection.Create;
    inherited Create;
  end;

  function TLKDictionary<TKey, TValue>.TryGetValue(const AKey: TKey; var AValue: TValue): Boolean;
  var
    LIndex: Integer;
  begin
    Result := Find(AKey, LIndex);
    if Result then
      AValue := Data[LIndex];
  end;

  function TLKDictionary<TKey, TValue>.ContainsKey(const AKey: TKey): Boolean;
  begin
    Result := IndexOf(AKey) > -1;
  end;
{$ELSE}
  constructor TLKDictionary<TKey, TValue>.Create(const AComparer: IEqualityComparer<TKey>);
  begin
    FLock := TCriticalSection.Create;
    inherited Create(AComparer);
  end;

  constructor TLKDictionary<TKey, TValue>.Create(ACapacity: Integer);
  begin
    FLock := TCriticalSection.Create;
    inherited Create(ACapacity);
  end;

  constructor TLKDictionary<TKey, TValue>.Create(ACapacity: Integer; const AComparer: IEqualityComparer<TKey>);
  begin
    FLock := TCriticalSection.Create;
    inherited Create(ACapacity, AComparer);
  end;

  constructor TLKDictionary<TKey, TValue>.Create(const Collection: TEnumerable<TPair<TKey, TValue>>; const AComparer: IEqualityComparer<TKey>);
  begin
    FLock := TCriticalSection.Create;
    inherited Create(Collection, AComparer);
  end;

  constructor TLKDictionary<TKey, TValue>.Create(const Collection: TEnumerable<TPair<TKey, TValue>>);
  begin
    FLock := TCriticalSection.Create;
    inherited Create(Collection);
  end;
{$ENDIF FPC}

destructor TLKDictionary<TKey, TValue>.Destroy;
begin
  FLock.Free;
  inherited;
end;

procedure TLKDictionary<TKey, TValue>.Lock;
begin
  FLock.Acquire;
end;

procedure TLKDictionary<TKey, TValue>.Unlock;
begin
  FLock.Release;
end;

{ TLKHashMap<TKey, TValue> }
{
function TLKHashMap<TKey, TValue>.Hash(const AKey: TKey): Integer;
const
  POSMASK = not Integer($80000000);
begin
  Result := POSMASK and ((POSMASK and LKSuperFastHash(@AKey, SizeOf(AKey))) + 1);
end;
}
{ TLKListBase<T> }

function TLKListBase<T>.Add(const AItem: T): Integer;
begin
  AddActual(AItem);
end;

procedure TLKListBase<T>.CheckCapacity;
begin
  Lock;
  try
    CheckCapacity(FCount);
  finally
    Unlock;
  end;
end;

procedure TLKListBase<T>.Add(const AItems: TArrayOfT);
var
  I: Integer;
begin
  for I := Low(AItems) to High(AItems) do
    AddActual(AItems[I]);
end;

procedure TLKListBase<T>.CheckCapacity(const ATotalRequiredCapacity: Integer);
begin
  Lock;
  try
    if ((Length(FArray) - ATotalRequiredCapacity) < FCapacityThreshold) then
    begin
      if (Round(Length(FArray) * FCapacityMultiplier)) > (ATotalRequiredCapacity + FCapacityThreshold) then
        SetLength(FArray, Round(Length(FArray) * FCapacityMultiplier)) // Expand using the Multiplier
      else
        SetLength(FArray, ATotalRequiredCapacity + FCapacityThreshold); // Expand to ensure everything fits
    end;
  finally
    Unlock;
  end;
end;

procedure TLKListBase<T>.Clear(const ACompact: Boolean = True);
begin
  Finalize(0, FCount);
  FCount := 0;
  if ACompact then
    SetLength(FArray, LKSL_LIST_CAPACITY_DEFAULT);
end;

procedure TLKListBase<T>.Compact;
begin
  CompactActual;
end;

procedure TLKListBase<T>.CompactActual;
begin
  Lock;
  try
    SetLength(FArray, FCount + FCapacityThreshold + Round(FCapacityMultiplier));
  finally
    Unlock;
  end;
end;

function TLKListBase<T>.Contains(const AItems: TArrayOfT): Boolean;
var
  I: Integer;
begin
  Lock;
  try
    Result := True; // Optimistic
    for I := Low(AItems) to High(AItems) do
    begin
      Result := IndexOf(AItems[I]) >= 0;
      if (not Result) then
        Break; // No point looking further if one of the items isn't present
    end;
  finally
    Unlock;
  end;
end;

constructor TLKListBase<T>.Create;
begin
  {$IFDEF FPC}
    inherited Create;
    InitializeArray;
  {$ELSE}
    Create(nil);
  {$ENDIF FPC}
end;

{$IFNDEF FPC}
  constructor TLKListBase<T>.Create(const AComparer: IComparer<T>);
  begin
    inherited Create;
    FComparer := AComparer;
    if FComparer = nil then
      FComparer := TComparer<T>.Default;
    InitializeArray;
  end;
{$ENDIF FPC}

function TLKListBase<T>.Contains(const AItem: T): Boolean;
begin
  Result := IndexOf(AItem) >= 0;
end;

procedure TLKListBase<T>.Delete(const AIndex: Integer);
begin
  DeleteActual(AIndex, fmFinalize, scmSmartCompact);
end;

procedure TLKListBase<T>.Delete(const AFirstIndex, ACount: Integer);
begin
  DeleteRange(AFirstIndex, ACount);
end;

procedure TLKListBase<T>.DeleteActual(const AIndex: Integer; const AFinalizeMode: TLKListFinalizeMode; const ASmartCompactMode: TLKListSmartCompactMode);
begin
  Lock;
  try
    if ValidateIndexInRange(AIndex) then
    begin
      Dec(FCount);
      if AFinalizeMode = fmFinalize then
      begin
        Move(AIndex + 1, AIndex, FCount - AIndex);
        Finalize(FCount, 1);
      end;
      if ASmartCompactMode = scmSmartCompact then
        SmartCompact;
    end;
  finally
    Unlock;
  end;
end;

procedure TLKListBase<T>.DeleteRange(const AIndex, ACount: Integer);
var
  I: Integer;
begin
  Lock;
  try
    for I := AIndex + ACount downto AIndex do
      Delete(I);
  finally
    Unlock;
  end;
end;

destructor TLKListBase<T>.Destroy;
begin

  inherited;
end;

procedure TLKListBase<T>.Finalize(const AIndex, ACount: Integer);
begin
  System.FillChar(FArray[AIndex], ACount * SizeOf(T), 0);
end;

function TLKListBase<T>.GetCapacity: Integer;
begin
  Lock;
  try
    Result := Length(FArray);
  finally
    Unlock;
  end;
end;

function TLKListBase<T>.GetCapacityMultiplier: Single;
begin
  Lock;
  try
    Result := FCapacityMultiplier;
  finally
    Unlock;
  end;
end;

function TLKListBase<T>.GetCapacityThreshold: Integer;
begin
  Lock;
  try
    Result := FCapacityThreshold;
  finally
    Unlock;
  end;
end;

function TLKListBase<T>.GetCount: Integer;
begin
  Lock;
  try
    Result := FCount;
  finally
    Unlock;
  end;
end;

function TLKListBase<T>.GetIsEmpty: Boolean;
begin
  Result := (Count = 0);
end;

function TLKListBase<T>.GetItemByIndex(const AIndex: Integer): T;
begin
  Lock;
  try
    if (AIndex > -1) and (AIndex <= FCount) then
      Result := FArray[AIndex]
    else
      raise ELKGenericCollectionsRangeException.CreateFmt('Index %d Out of Range.', [AIndex]);
  finally
    Unlock;
  end;
end;

function TLKListBase<T>.IndexOf(const AItem: T): Integer;
var
  I: Integer;
begin
  Result := -1; // Pessimistic
  Lock;
  try
    for I := 0 to FCount - 1 do
      if {$IFDEF FPC}CompareByte(FArray[I], AItem, SizeOf(AItem)) > 0{$ELSE}FComparer.Compare(FArray[I], AItem) = 0{$ENDIF FPC} then
      begin
        Result := I;
        Break; // No point going further if we've already found it
      end;
  finally
    Unlock;
  end;
end;

procedure TLKListBase<T>.InitializeArray;
begin
  FCount := 0;
  SetLength(FArray, LKSL_LIST_CAPACITY_DEFAULT);
  FCapacityThreshold := LKSL_LIST_THRESHOLD_DEFAULT;
  FCapacityMultiplier := LKSL_LIST_MULTIPLIER_DEFAULT;
end;

function TLKListBase<T>.AddActual(const AItem: T): Integer;
begin
  Lock;
  try
    CheckCapacity(FCount + 1);
    Result := FCount;
    FArray[Result] := AItem;
    Inc(FCount);
  finally
    Unlock;
  end;
end;

procedure TLKListBase<T>.InsertActual(const AItem: T; const AIndex: Integer);
begin
  CheckCapacity(FCount + 1); // Ensure we have enough free slots in the Array to shift into
  Move(AIndex, AIndex + 1, FCount - AIndex); // Shift everything Right
  FArray[AIndex] := AItem; // Assign our Item to its Index
  Inc(FCount); // Incrememnt the Count
end;

procedure TLKListBase<T>.Iterate(const AIterateCallback: TIterateCallbackUnbound; const AIterateDirection: TLKListDirection);
var
  I: Integer;
begin
  Lock;
  try
    case AIterateDirection of
      ldLeft: for I := FCount - 1 downto 0 do AIterateCallback(I, FArray[I]); // Reverse-order
      ldRight: for I := 0 to FCount - 1 do AIterateCallback(I, FArray[I]); // Forward-order
    end;
  finally
    Unlock;
  end;
end;

procedure TLKListBase<T>.Iterate(const AIterateCallback: TIterateCallbackUnbound; const AFrom, ATo: Integer);
var
  I: Integer;
begin
  Lock;
  try
    if ValidateRangeInArray(AFrom, ATo) then
    begin
      if AFrom < ATo then
      begin
        for I := AFrom to ATo do
          AIterateCallback(I, FArray[I]);
      end else
      begin
        for I := ATo downto AFrom do
          AIterateCallback(I, FArray[I]);
      end;
    end;
  finally
    Unlock;
  end;
end;

procedure TLKListBase<T>.Iterate(const AIterateCallback: TIterateCallbackOfObject; const AIterateDirection: TLKListDirection);
var
  I: Integer;
begin
  Lock;
  try
    case AIterateDirection of
      ldLeft: for I := FCount - 1 downto 0 do AIterateCallback(I, FArray[I]); // Reverse-order
      ldRight: for I := 0 to FCount - 1 do AIterateCallback(I, FArray[I]); // Forward-order
    end;
  finally
    Unlock;
  end;
end;

procedure TLKListBase<T>.Iterate(const AIterateCallback: TIterateCallbackOfObject; const AFrom, ATo: Integer);
var
  I: Integer;
begin
  Lock;
  try
    if ValidateRangeInArray(AFrom, ATo) then
    begin
      if AFrom < ATo then
      begin
        for I := AFrom to ATo do
          AIterateCallback(I, FArray[I]);
      end else
      begin
        for I := ATo downto AFrom do
          AIterateCallback(I, FArray[I]);
      end;
    end;
  finally
    Unlock;
  end;
end;

{$IFDEF SUPPORTS_REFERENCETOMETHOD}
  procedure TLKListBase<T>.Iterate(const AIterateCallback: TIterateCallbackAnon; const AFrom, ATo: Integer);
  var
    I: Integer;
  begin
    Lock;
    try
      if ValidateRangeInArray(AFrom, ATo) then
      begin
        if AFrom < ATo then
        begin
          for I := AFrom to ATo do
            AIterateCallback(I, FArray[I]);
        end else
        begin
          for I := ATo downto AFrom do
            AIterateCallback(I, FArray[I]);
        end;
      end;
    finally
      Unlock;
    end;
  end;

  procedure TLKListBase<T>.Iterate(const AIterateCallback: TIterateCallbackAnon; const AIterateDirection: TLKListDirection = ldRight);
  var
    I: Integer;
  begin
    Lock;
    try
      case AIterateDirection of
        ldLeft: for I := FCount - 1 downto 0 do AIterateCallback(I, FArray[I]); // Reverse-order
        ldRight: for I := 0 to FCount - 1 do AIterateCallback(I, FArray[I]); // Forward-order
      end;
    finally
      Unlock;
    end;
  end;
{$ENDIF SUPPORTS_REFERENCETOMETHOD}

procedure TLKListBase<T>.Move(const AFromIndex, AToIndex, ACount: Integer);
begin

  System.Move(FArray[AFromIndex], FArray[AToIndex], ACount * SizeOf(T));
end;


procedure TLKListBase<T>.QuickSort(const ASortHandler: TLKSortHandlerT; ALow, AHigh: Integer; const ASortOrder: TLKListSortOrder);
var
  I, J: Integer;
  LPivot, LTemp: T;
begin
  if (Length(FArray) = 0) or ((AHigh - ALow) <= 0) then
    Exit;
  repeat
    I := ALow;
    J := AHigh;
    LPivot := FArray[ALow + (AHigh - ALow) shr 1];
    repeat
      case ASortOrder of
        soAscending: begin
                       while ASortHandler.ALessThanB(FArray[I], LPivot) do
                         Inc(I);
                       while ASortHAndler.AGreaterThanB(FArray[J], LPivot) do
                         Dec(J);
                     end;
        soDescending: begin
                       while ASortHandler.ALessThanB(LPivot, FArray[I]) do
                         Inc(I);
                       while ASortHAndler.AGreaterThanB(LPivot, FArray[J]) do
                         Dec(J);
                      end;
      end;
      if I <= J then
      begin
        if I <> J then
        begin
          LTemp := FArray[I];
          FArray[I] := FArray[J];
          FArray[J] := LTemp;
        end;
        Inc(I);
        Dec(J);
      end;
    until I > J;
    if ALow < J then
      QuickSort(ASortHandler, ALow, J, ASortOrder);
    ALow := I;
  until I >= AHigh;
end;

procedure TLKListBase<T>.Remove(const AItems: TArrayOfT);
var
  I: Integer;
begin
  for I := Low(AItems) to High(AItems) do
    RemoveActual(AItems[I]);
end;

function TLKListBase<T>.Remove(const AItem: T): Integer;
begin
  RemoveActual(AItem);
end;

function TLKListBase<T>.RemoveActual(const AItem: T): Integer;
begin
  Result := IndexOf(AItem);
  if Result >= 0 then
    DeleteActual(Result, fmFinalize, scmSmartCompact);
end;

procedure TLKListBase<T>.SetCapacityMultiplier(const AMultiplier: Single);
begin
  // Sanity Check on Multiplier
  if AMultiplier < LKSL_LIST_MULTIPLIER_MINIMUM then
    raise ELKGenericCollectionsLimitException.CreateFmt('Minimum Capacity Multiplier is %n', [LKSL_LIST_MULTIPLIER_MINIMUM])
  else if AMultiplier > LKSL_LIST_MULTIPLIER_MAXIMUM then
    raise ELKGenericCollectionsLimitException.CreateFmt('Maximum Capacity Multiplier is %n', [LKSL_LIST_MULTIPLIER_MAXIMUM]);
  // If we got this far, we're ready to change our Multiplier
  Lock;
  try
    FCapacityMultiplier := AMultiplier;
  finally
    Unlock;
  end;
end;

procedure TLKListBase<T>.SetCapacityThreshold(const AThreshold: Integer);
begin
  // Sanity Check on Threshold
  if AThreshold < LKSL_LIST_THRESHOLD_MINIMUM then
    raise ELKGenericCollectionsLimitException.CreateFmt('Minimum Capacity Threshold is %d', [LKSL_LIST_THRESHOLD_MINIMUM]);
  // If we got this far, we're ready to change our Threshold
  Lock;
  try
    FCapacityThreshold := AThreshold;
    CheckCapacity; // Adjust the Array Capacity if necessary
  finally
    Unlock;
  end;
end;

procedure TLKListBase<T>.SmartCompact;
begin
  Lock;
  try
    if Length(FArray) > Round(FCount * FCapacityMultiplier) + FCapacityThreshold then
      CompactActual;
  finally
    Unlock;
  end;
end;

procedure TLKListBase<T>.Sort(const ASortHandler: TLKSortHandlerT; const ASortOrder: TLKListSortOrder = soAscending);
begin
  QuickSort(ASortHandler, 0, FCount - 1, ASortOrder);
end;

function TLKListBase<T>.ValidateIndexInRange(const AIndex: Integer): Boolean;
begin
  Result := (AIndex < FCount);
  if (not Result) then
    raise ELKGenericCollectionsRangeException.CreateFmt('Index Out of Bounds: %d', [AIndex]);
end;

function TLKListBase<T>.ValidateRangeInArray(const AFrom, ATo: Integer): Boolean;
begin
  Result := False;
  Lock;
  try
    if (AFrom < 0) or (AFrom >= FCount) then
      raise ELKGenericCollectionsRangeException.CreateFmt('"From" Index Out of Range: %d', [AFrom]);
    if (ATo < 0) or (ATo >= FCount) then
      raise ELKGenericCollectionsRangeException.CreateFmt('"To" Index Out of Range: %d', [AFrom]);
  finally
    Unlock;
  end;
  Result := True;
end;

{ TLKList<T> }

procedure TLKList<T>.Insert(const AItem: T; const AIndex: Integer);
begin
  Lock;
  try
    if ValidateIndexInRange(AIndex) then
      InsertActual(AItem, AIndex);
  finally
    Unlock;
  end;
end;

{ TLKObjectList<T> }

procedure TLKObjectList<T>.Clear(const ACompact: Boolean);
var
  I: Integer;
begin
  Lock;
  try
    if FOwnsObjects then
    begin
      for I := 0 to FCount - 1 do
        {$IFDEF FPC}FArray[I].Free;{$ELSE}FArray[I].DisposeOf;{$ENDIF FPC}
    end;
    inherited;
  finally
    Unlock;
  end;
end;

constructor TLKObjectList<T>.Create(const AOwnsObjects: Boolean = True);
begin
  inherited Create;
  FOwnsObjects := AOwnsObjects;
end;

{$IFNDEF FPC}
  constructor TLKObjectList<T>.Create(const AComparer: IComparer<T>; const AOwnsObjects: Boolean);
  begin
    inherited Create(AComparer);
    FOwnsObjects := True;
  end;
{$ENDIF FPC}

procedure TLKObjectList<T>.Delete(const AIndex: Integer);
begin
  Lock;
  try
    if FOwnsObjects then
      {$IFDEF FPC}
        FArray[AIndex].Free;
      {$ELSE}
        FArray[AIndex].DisposeOf;
      {$ENDIF FPC}
    inherited;
  finally
    Unlock;
  end;
end;

destructor TLKObjectList<T>.Destroy;
begin
  Clear;
  inherited;
end;

function TLKObjectList<T>.GetOwnsObjects: Boolean;
begin
  Lock;
  try
    Result := FOwnsObjects;
  finally
    Unlock;
  end;
end;

procedure TLKObjectList<T>.SetOwnsObjects(const AOwnsObjects: Boolean);
begin
  Lock;
  try
    FOwnsObjects := AOwnsObjects;
  finally
    Unlock;
  end;
end;

{ TLKSortedListBase<T> }

function TLKSortedListBase<T>.GetSortedPosition(const AItem: T): Integer;
var
  LIndex, LLow, LHigh: Integer;
begin
  Result := 0;
  LLow := 0;
  LHigh := FCount - 1;
  if LHigh = - 1 then
    Exit;
  if LLow < LHigh then
  begin
    while (LHigh - LLow > 1) do
    begin
      LIndex := (LHigh + LLow) div 2;
      if ALessThanOrEqualB(AItem, FArray[LIndex]) then
        LHigh := LIndex
      else
        LLow := LIndex;
    end;
  end;
  if ALessThanB(FArray[LHigh], AItem) then
    Result := LHigh + 1
  else if ALessThanB(FArray[LLow], AItem) then
    Result := LLow + 1
  else
    Result := LLow;
end;

{ TLKSortedList<T> }

function TLKSortedList<T>.AddActual(const AItem: T): Integer;
begin
  Lock;
  try
    CheckCapacity(FCount + 1);
    Result := GetSortedPosition(AItem);
    if Result = FCount then
      inherited AddActual(AItem)
    else
      InsertActual(AItem, Result);
  finally
    Unlock;
  end;
end;

{ TLKSortedObjectList<T> }

procedure TLKSortedObjectList<T>.Clear(const ACompact: Boolean);
var
  I: Integer;
begin
  Lock;
  try
    if FOwnsObjects then
    begin
      for I := 0 to FCount - 1 do
        {$IFDEF FPC}
          FArray[I].Free;
        {$ELSE}
          FArray[I].DisposeOf;
        {$ENDIF FPC}
    end;
    inherited;
  finally
    Unlock;
  end;
end;

constructor TLKSortedObjectList<T>.Create(const AOwnsObjects: Boolean);
begin
  inherited Create;
  FOwnsObjects := AOwnsObjects;
end;

{$IFNDEF FPC}
  constructor TLKSortedObjectList<T>.Create(const AComparer: IComparer<T>; const AOwnsObjects: Boolean);
  begin
    inherited Create(AComparer);
    FOwnsObjects := AOwnsObjects;
  end;
{$ENDIF FPC}

procedure TLKSortedObjectList<T>.Delete(const AIndex: Integer);
begin
  Lock;
  try
    if FOwnsObjects then
      {$IFDEF FPC}
        FArray[AIndex].Free;
      {$ELSE}
        FArray[AIndex].DisposeOf;
      {$ENDIF FPC}
    inherited;
  finally
    Unlock;
  end;
end;

destructor TLKSortedObjectList<T>.Destroy;
begin
  Clear;
  inherited;
end;

function TLKSortedObjectList<T>.GetOwnsObjects: Boolean;
begin
  Lock;
  try
    Result := FOwnsObjects;
  finally
    Unlock;
  end;
end;

procedure TLKSortedObjectList<T>.SetOwnsObjects(const AOwnsObjects: Boolean);
begin
  Lock;
  try
    FOwnsObjects := AOwnsObjects;
  finally
    Unlock;
  end;
end;
{$IFNDEF FPC}
  { TLKCenteredList<T> }

  function TLKCenteredList<T>.Add(const AItem: T; const ADirection: TLKListDirection): Integer;
  begin
    case ADirection of
      ldLeft: Result := AddLeft(AItem);
      ldRight: Result := AddRight(Aitem);
    end;
  end;

  procedure TLKCenteredList<T>.Add(const AItems: TArrayOfT; const ADirection: TLKListDirection);
  var
    I: Integer;
  begin
    for I := System.Low(AItems) to System.High(AItems) do
      Add(AItems[I], ADirection);
  end;

  function TLKCenteredList<T>.AddLeft(const AItem: T): Integer;
  begin
    if (TryCenterAvailable(AItem)) then
      Result := 0
    else
    begin
      LockLeft;
      try
        Result := FCountLeft;
        FArrayLeft[Result] := AItem;
        Inc(FCountLeft);
        CheckCapacityLeft;
      finally
        UnlockLeft;
      end;
    end;
  end;

  procedure TLKCenteredList<T>.AddLeft(const AItems: TArrayOfT);
  var
    I: Integer;
  begin
    for I := System.Low(AItems) to System.High(AItems) do
      AddLeft(AItems[I]);
  end;

  function TLKCenteredList<T>.AddRight(const AItem: T): Integer;
  begin
    if (TryCenterAvailable(AItem)) then
      Result := 0
    else
    begin
      LockRight;
      try
        Result := FCountRight;
        FArrayRight[Result] := AItem;
        Inc(FCountRight);
        CheckCapacityRight;
      finally
        UnlockRight;
      end;
    end;
  end;

  procedure TLKCenteredList<T>.AddRight(const AItems: TArrayOfT);
  var
    I: Integer;
  begin
    for I := System.Low(AItems) to System.High(AItems) do
      AddRight(AItems[I]);
  end;

  procedure TLKCenteredList<T>.CheckCapacityLeft;
  begin
    LockLeft;
    try
      if ((Length(FArrayLeft) - FCountLeft) < FCapacityThreshold) then
        SetLength(FArrayLeft, Round(Length(FArrayLeft) * FCapacityMultiplier));
    finally
      UnlockLeft;
    end;
  end;

  procedure TLKCenteredList<T>.CheckCapacityRight;
  begin
    LockRight;
    try
      if ((Length(FArrayRight) - FCountRight) < FCapacityThreshold) then
        SetLength(FArrayRight, Round(Length(FArrayRight) * FCapacityMultiplier));
    finally
      UnlockRight;
    end;
  end;

  procedure TLKCenteredList<T>.Compact;
  begin
    Lock;
    try
      SetLength(FArrayLeft, (Length(FArrayLeft) - FCountLeft) + FCapacityThreshold + 1);
      SetLength(FArrayRight, (Length(FArrayRight) - FCountRight) + FCapacityThreshold + 1);
    finally
      Unlock;
    end;
  end;

  constructor TLKCenteredList<T>.Create;
  begin
    inherited Create;
    FCenterAssigned := False;
    FCountLeft := 0;
    FCountRight := 0;
    FLockLeft := TCriticalSection.Create;
    FLockRight := TCriticalSection.Create;
    FLockCenter := TCriticalSection.Create;
    // We default the Capacity of the Left and Right Arrays to 10 each.
    // This equates to 21 default Capacity (including Center)
    SetLength(FArrayLeft, LKSL_LIST_CAPACITY_DEFAULT);
    SetLength(FArrayRight, LKSL_LIST_CAPACITY_DEFAULT);
    FCapacityThreshold := LKSL_LIST_THRESHOLD_DEFAULT;
    FCapacityMultiplier := LKSL_LIST_MULTIPLIER_DEFAULT;
  end;

  procedure TLKCenteredList<T>.Delete(const AIndex: Integer);
  begin
    if AIndex = 0 then
    begin
      if ValidateDeleteCenter then
        DeleteCenter
    end
    else if AIndex < 0 then
    begin
      if ValidateDeleteLeft((-AIndex) - 1) then
        DeleteLeft((-AIndex) - 1) // Invert AIndex to provide a positive index
    end
    else
    begin
      if ValidateDeleteRight(AIndex - 1) then
        DeleteRight(AIndex - 1);
    end;
  end;

  procedure TLKCenteredList<T>.Delete(const AIndices: array of Integer);
  var
    I, LOffset: Integer;
  begin
    LOffset := 0;
    Lock;
    try
      for I := System.Low(AIndices) to System.High(AIndices) do
      begin
        if I = 0 then
          LOffset := 0;
        Delete(AIndices[I - LOffset]);
        Inc(LOffset);
      end;
    finally
      Unlock;
    end;
  end;

  procedure TLKCenteredList<T>.DeleteCenter;
  var
    I: Integer;
  begin
    LockCenter;
    try
      LockRight;
      try
        if FCountRight > 0 then
        begin
          FCenter := FArrayRight[0];
          FCenterAssigned := True;
          if FCountRight > 1 then
          begin
            Dec(FCountRight);
            Move(FArrayRight, 1, 0, FCountRight);
            Finalize(FArrayRight, FCountRight, 1);
          end else
          begin
            Dec(FCountRight);
            Finalize(FArrayRight, 0, 1); // Finalize the Right Array
          end;
        end else
        begin
          System.FillChar(FCenter, SizeOf(T), 0); // Finalize the Center
          FCenterAssigned := False;
        end;
      finally
        UnlockRight;
      end;
    finally
      UnlockCenter;
    end;
  end;

  procedure TLKCenteredList<T>.DeleteLeft(const AIndex: Integer);
  var
    I: Integer;
  begin
    LockLeft;
    try
      Dec(FCountLeft);
      Move(FArrayLeft, AIndex + 1, AIndex, FCountLeft - AIndex);
      Finalize(FArrayLeft, FCountLeft, 1);
    finally
      UnlockLeft;
    end;
  end;

  procedure TLKCenteredList<T>.DeleteRange(const ALow, AHigh: Integer);
  var
    I, LOffset: Integer;
  begin
    LOffset := 0;
    Lock;
    try
      for I := ALow to AHigh do
      begin
        if I = 0 then
          LOffset := 0;
        Delete(I - LOffset);
        Inc(LOffset);
      end;
    finally
      Unlock;
    end;
  end;

  procedure TLKCenteredList<T>.DeleteRight(const AIndex: Integer);
  var
    I: Integer;
  begin
    LockRight;
    try
      Dec(FCountRight);
      Move(FArrayRight, AIndex + 1, AIndex, FCountRight - AIndex);
      Finalize(FArrayRight, FCountRight, 1);
    finally
      UnlockRight;
    end;
  end;

  destructor TLKCenteredList<T>.Destroy;
  begin
    FLockLeft.Free;
    FLockRight.Free;
    FLockCenter.Free;
    inherited;
  end;

  procedure TLKCenteredList<T>.Finalize(var AArray: TArrayOfT; const AIndex, ACount: Integer);
  begin
    System.FillChar(AArray[AIndex], ACount * SizeOf(T), 0);
  end;

  function TLKCenteredList<T>.GetCapacity: Integer;
  begin
    Result := Length(FArrayLeft) + Length(FArrayRight) + 1;
  end;

  function TLKCenteredList<T>.GetCapacityLeft: Integer;
  begin
    LockLeft;
    try
      Result := Length(FArrayLeft);
    finally
      UnlockLeft;
    end;
  end;

  function TLKCenteredList<T>.GetCapacityMultiplier: Single;
  begin
    Lock;
    try
      Result := FCapacityMultiplier;
    finally
      Unlock;
    end;
  end;

  function TLKCenteredList<T>.GetCapacityRight: Integer;
  begin
    LockRight;
    try
      Result := Length(FArrayRight);
    finally
      UnlockRight;
    end;
  end;

  function TLKCenteredList<T>.GetCapacityThreshold: Integer;
  begin
    Lock;
    try
      Result := FCapacityThreshold;
    finally
      Unlock;
    end;
  end;

  function TLKCenteredList<T>.GetCount: Integer;
  const
    // Ordinarily, if Center isn't assigned, then the Count will be 0 anyway!
    // There is the possibility of exceptions to this general rule, however!
    CENTER_ADDITION: Array[Boolean] of Integer = (0, 1);
  begin
    Lock;
    try
      Result := GetCountLeft + GetCountRight + CENTER_ADDITION[FCenterAssigned];
    finally
      Unlock;
    end;
  end;

  function TLKCenteredList<T>.GetCountLeft: Integer;
  begin
    LockLeft;
    try
      Result := FCountLeft;
    finally
      UnlockLeft;
    end;
  end;

  function TLKCenteredList<T>.GetCountRight: Integer;
  begin
    LockRight;
    try
      Result := FCountRight;
    finally
      UnlockRight;
    end;
  end;

  function TLKCenteredList<T>.GetItemByIndex(const AIndex: Integer): T;
  begin
    if AIndex = 0 then
      Result := GetItemCenter
    else if AIndex < 0 then
      Result := GetItemLeft((-AIndex) - 1)
    else
      Result := GetItemRight(AIndex - 1);
  end;

  function TLKCenteredList<T>.GetItemCenter: T;
  begin
    LockCenter;
    try
      if FCenterAssigned then
        Result := FCenter
      else
        raise ELKGenericCollectionsRangeException.Create('Index Out of Bounds: 0');
    finally
      UnlockCenter;
    end;
  end;

  function TLKCenteredList<T>.GetItemLeft(const AIndex: Integer): T;
  begin
    LockLeft;
    try
      if AIndex < FCountLeft then
        Result := FArrayLeft[AIndex]
      else
        raise ELKGenericCollectionsRangeException.CreateFmt('Index Out of Bounds: %d', [-(AIndex + 1)]);
    finally
      UnlockLeft;
    end;
  end;

  function TLKCenteredList<T>.GetItemRight(const AIndex: Integer): T;
  begin
    LockRight;
    try
      if AIndex < FCountRight then
        Result := FArrayRight[AIndex]
      else
        raise ELKGenericCollectionsRangeException.CreateFmt('Index Out of Bounds: %d', [AIndex]);
    finally
      UnlockRight;
    end;
  end;

  function TLKCenteredList<T>.GetRangeHigh: Integer;
  begin
    LockRight;
    try
      Result := FCountRight;
      if (not FCenterAssigned) then
        Dec(Result);
    finally
      UnlockRight;
    end;
  end;

  function TLKCenteredList<T>.GetRangeLow: Integer;
  begin
    LockLeft;
    try
      Result := -FCountLeft;
    finally
      UnlockLeft;
    end;
  end;

  procedure TLKCenteredList<T>.Insert(const AItem: T; const AIndex: Integer; const AShiftDirection: TLKListDirection = ldRight);
  begin
    if AIndex = 0 then
      InsertCenter(AItem, AShiftDirection)
    else if AIndex < 0 then
      InsertLeft(AItem, (-AIndex) - 1, AShiftDirection)
    else
      InsertRight(AItem, AIndex - 1, AShiftDirection);
  end;

  procedure TLKCenteredList<T>.InsertCenter(const AItem: T; const AShiftDirection: TLKListDirection = ldRight);
  begin
    LockCenter;
    try
      if not (TryCenterAvailable(AItem)) then
      begin
        case AShiftDirection of
          ldLeft: begin
                    LockLeft;
                    try
                      if FCountLeft > 0 then
                      begin
                        Move(FArrayLeft, 0, 1, FCountLeft);
                        FArrayLeft[0] := FCenter;
                        Inc(FCountLeft);
                        CheckCapacityLeft;
                      end;
                    finally
                      UnlockLeft;
                    end;
                  end;
          ldRight: begin
                     LockRight;
                     try
                       if FCountRight > 0 then
                       begin
                         Move(FArrayRight, 0, 1, FCountRight);
                         FArrayRight[0] := FCenter;
                         Inc(FCountRight);
                         CheckCapacityRight;
                       end;
                     finally
                       UnlockRight;
                     end;
                   end;
        end;
        FCenter := AItem;
        FCenterAssigned := True;
      end;
    finally
      UnlockCenter;
    end;
  end;

  procedure TLKCenteredList<T>.InsertLeft(const AItem: T; const AIndex: Integer; const AShiftDirection: TLKListDirection = ldRight);
  begin
    if AIndex > FCountLeft then
      raise ELKGenericCollectionsRangeException.CreateFmt('Index %d Out of Bounds.', [-(AIndex + 1)])
    else
    begin
      case AShiftDirection of
        ldLeft: begin
                  LockLeft;
                  try
                    // We're actually shifting to the RIGHT (remember, it's inverted)
                    Move(FArrayLeft, AIndex, AIndex + 1, FCountLeft - AIndex);
                    FArrayLeft[AIndex] := AItem;
                    Inc(FCountLeft);
                    CheckCapacityLeft;
                  finally
                    UnlockLeft;
                  end;
                end;
        ldRight: begin
                   LockRight;
                   try
                     // We're actually shifting to the LEFT (remember, it's inverted)
                     LockCenter;
                     try
                       InsertRight(FCenter, 0); // Move the Center to position 0 of the RIGHT Array
                       FCenter := FArrayLeft[0]; // Move the Right-most item in the Left Array to Center
                       FCenterAssigned := True;
                     finally
                       UnlockCenter;
                     end;
                     Move(FArrayLeft, 1, 0, AIndex);
                     FArrayLeft[AIndex] := AItem; // Assign the Item to the index
                     CheckCapacityRight;
                   finally
                     UnlockRight;
                   end;
                 end;
      end;
    end;
  end;

  procedure TLKCenteredList<T>.InsertRight(const AItem: T; const AIndex: Integer; const AShiftDirection: TLKListDirection = ldRight);
  begin
    if AIndex > FCountRight then
      raise ELKGenericCollectionsRangeException.CreateFmt('Index %d Out of Bounds.', [AIndex + 1])
    else
    begin
      case AShiftDirection of
        ldLeft: begin
                  LockLeft;
                  try
                    LockCenter;
                    try
                      InsertLeft(FCenter, 0, ldLeft); // Move the Center position to 0 of the LEFT Array
                      FCenter := FArrayRight[0]; // Move the left-most item in the Left Array to Center
                      FCenterAssigned := True;
                    finally
                      UnlockCenter;
                    end;
                    Move(FArrayRight, 1, 0, AIndex);
                    FArrayRight[AIndex] := AItem;
                    CheckCapacityLeft;
                  finally
                    UnlockLeft;
                  end;
                end;
        ldRight: begin
                   LockRight;
                   try
                     Move(FArrayRight, AIndex, AIndex + 1, FCountRight - AIndex);
                     FArrayRight[AIndex] := AItem;
                     Inc(FCountRight);
                     CheckCapacityRight;
                   finally
                     UnlockRight;
                   end;
                 end;
      end;
    end;
  end;

  procedure TLKCenteredList<T>.Lock;
  begin
    LockCenter;
    LockLeft;
    LockRight;
  end;

  procedure TLKCenteredList<T>.LockCenter;
  begin
    FLockCenter.Acquire;
  end;

  procedure TLKCenteredList<T>.LockLeft;
  begin
    FLockLeft.Acquire;
  end;

  procedure TLKCenteredList<T>.LockRight;
  begin
    FLockRight.Acquire;
  end;

  procedure TLKCenteredList<T>.Move(var AArray: TArrayOfT; const AFromIndex, AToIndex, ACount: Integer);
  begin
    System.Move(AArray[AFromIndex], AArray[AToIndex], ACount * SizeOf(T));
  end;

  procedure TLKCenteredList<T>.SetCapacityMultiplier(const AMultiplier: Single);
  begin
    // Sanity Check on Multiplier
    if AMultiplier < LKSL_LIST_MULTIPLIER_MINIMUM then
      raise ELKGenericCollectionsLimitException.CreateFmt('Minimum Capacity Multiplier is %n', [LKSL_LIST_MULTIPLIER_MINIMUM])
    else if AMultiplier > LKSL_LIST_MULTIPLIER_MAXIMUM then
      raise ELKGenericCollectionsLimitException.CreateFmt('Maximum Capacity Multiplier is %n', [LKSL_LIST_MULTIPLIER_MAXIMUM]);
    // If we got this far, we're ready to change our Multiplier
    Lock;
    try
      FCapacityMultiplier := AMultiplier;
    finally
      Unlock;
    end;
  end;

  procedure TLKCenteredList<T>.SetCapacityThreshold(const AThreshold: Integer);
  begin
    // Sanity Check on Threshold
    if AThreshold < LKSL_LIST_THRESHOLD_MINIMUM then
      raise ELKGenericCollectionsLimitException.CreateFmt('Minimum Capacity Threshold is %d', [LKSL_LIST_THRESHOLD_MINIMUM]);
    // If we got this far, we're ready to change our Threshold
    Lock;
    try
      FCapacityThreshold := AThreshold;
      CheckCapacityLeft; // Adjust the Left Array Capacity if necessary
      CheckCapacityRight; // Adjust the Right Array Capacity if necessary
    finally
      Unlock;
    end;
  end;

  procedure TLKCenteredList<T>.SetItemByIndex(const AIndex: Integer; const AItem: T);
  begin
    if AIndex = 0 then
      SetItemCenter(AItem)
    else if AIndex < 0 then
      SetItemLeft((-AIndex) - 1, AItem)
    else
      SetItemRight(AIndex - 1, AItem);
  end;

  procedure TLKCenteredList<T>.SetItemCenter(const AItem: T);
  begin
    LockCenter;
    try
      FCenter := AItem;
      FCenterAssigned := True;
    finally
      UnlockCenter;
    end;
  end;

  procedure TLKCenteredList<T>.SetItemLeft(const AIndex: Integer; const AItem: T);
  begin
    LockLeft;
    try
      if AIndex < FCountLeft then
        FArrayLeft[AIndex] := AItem
      else
        raise ELKGenericCollectionsRangeException.CreateFmt('Index Out of Range: %d', [-(AIndex + 1)]);
    finally
      UnlockLeft;
    end;
  end;

  procedure TLKCenteredList<T>.SetItemRight(const AIndex: Integer; const AItem: T);
  begin
    LockRight;
    try
      if AIndex < FCountRight then
        FArrayRight[AIndex] := AItem
      else
        raise ELKGenericCollectionsRangeException.CreateFmt('Index Out of Bounds: %d', [AIndex]);
    finally
      UnlockRight;
    end;
  end;

  procedure TLKCenteredList<T>.Swap(const AFrom, ATo: Integer);
  var
    LTemp: T;
    LFrom, LTo: ^T;
  begin
    if AFrom = 0 then
      LFrom := @FCenter
    else if AFrom < 0 then
      LFrom := @FArrayLeft[-(AFrom) - 1]
    else
      LFrom := @FArrayRight[AFrom - 1];

    if ATo = 0 then
      LTo := @FCenter
    else if ATo < 0 then
      LTo := @FArrayLeft[-(ATo) - 1]
    else
      LTo := @FArrayRight[ATo - 1];

      LTemp := LFrom^;
      LFrom^ := LTo^;
      LTo^ := LTemp;
  end;

  function TLKCenteredList<T>.TryCenterAvailable(const AItem: T): Boolean;
  begin
    Result := False;
    LockCenter;
    try
      if not (FCenterAssigned) then
      begin
        Result := True;
        FCenter := AItem;
        FCenterAssigned := True;
      end;
    finally
      UnlockCenter;
    end;
  end;

  procedure TLKCenteredList<T>.Unlock;
  begin
    UnlockCenter;
    UnlockLeft;
    UnlockRight;
  end;

  procedure TLKCenteredList<T>.UnlockCenter;
  begin
    FLockCenter.Release;
  end;

  procedure TLKCenteredList<T>.UnlockLeft;
  begin
    FLockLeft.Release;
  end;

  procedure TLKCenteredList<T>.UnlockRight;
  begin
    FLockRight.Release;
  end;

  function TLKCenteredList<T>.ValidateDeleteCenter: Boolean;
  begin
    Result := FCenterAssigned;
    if not (Result) then
      raise ELKGenericCollectionsRangeException.Create('Index Out of Bounds: 0')
  end;

  function TLKCenteredList<T>.ValidateDeleteLeft(const AIndex: Integer): Boolean;
  begin
    Result := (AIndex < FCountLeft);
    if (not Result) then
      raise ELKGenericCollectionsRangeException.CreateFmt('Index Out of Bounds: %d', [-(AIndex + 1)]);
  end;

  function TLKCenteredList<T>.ValidateDeleteRight(const AIndex: Integer): Boolean;
  begin
    Result := (AIndex < FCountRight);
    if (not Result) then
      raise ELKGenericCollectionsRangeException.CreateFmt('Index Out of Bounds: %d', [AIndex + 1]);
  end;

  { TLKCenteredObjectList<T> }

  constructor TLKCenteredObjectList<T>.Create(const AOwnsObjects: Boolean);
  begin
    inherited Create;
    FOwnsObjects := AOwnsObjects;
  end;

  procedure TLKCenteredObjectList<T>.DeleteCenter;
  begin
    if FOwnsObjects then
      FCenter.DisposeOf;
    inherited;
  end;

  procedure TLKCenteredObjectList<T>.DeleteLeft(const AIndex: Integer);
  begin
    if FOwnsObjects then
      FArrayLeft[AIndex].DisposeOf;
    inherited;
  end;

  procedure TLKCenteredObjectList<T>.DeleteRight(const AIndex: Integer);
  begin
    if FOwnsObjects then
      FArrayRight[AIndex].DisposeOf;
    inherited;
  end;

  { TLKTreeNode<T> }

  constructor TLKTreeNode<T>.Create(const AParent: TLKTreeNode<T>; const AValue: T);
  begin
    inherited Create;

    FParent := AParent;
    FChildren := TLKObjectList<TLKTreeNode<T>>.Create;
    FValue := AValue;
  end;

  constructor TLKTreeNode<T>.Create(const AParent: TLKTreeNode<T>);
  begin
    Create(AParent, Default(T));
  end;

  constructor TLKTreeNode<T>.Create(const AValue: T);
  begin
    Create(nil, AValue);
  end;

  constructor TLKTreeNode<T>.Create;
  begin
    Create(nil, Default(T));
  end;

  destructor TLKTreeNode<T>.Destroy;
  begin
    FChildren.Free;

    inherited;
  end;

  procedure TLKTreeNode<T>.DoAncestorChanged;
  begin
    PreOrderWalk(procedure(const Node: TLKTreeNode<T>)
                 begin
                   Node.AncestorChanged;
                 end);
  end;

  function TLKTreeNode<T>.GetRootNode: TLKTreeNode<T>;
  begin
    Lock;
    try
      if IsRoot then
        Result := Self
      else
        Result := Parent.RootNode;
    finally
      Unlock;
    end;
  end;

  function TLKTreeNode<T>.GetChildCount: Integer;
  begin
    Lock;
    try
      Result := FChildren.Count;
    finally
      Unlock;
    end;
  end;

  function TLKTreeNode<T>.GetChildren(const AIndex: Integer): TLKTreeNode<T>;
  begin
    Lock;
    try
      Result := FChildren[AIndex];
    finally
      Unlock;
    end;
  end;

  function TLKTreeNode<T>.GetIndexAsChild: Integer;
  begin
    if Parent = nil then
      Result := -1
    else
    begin
      Lock;
      try
        Result := Parent.IndexOf(Self);
      finally
        Unlock;
      end;
    end;
  end;

  function TLKTreeNode<T>.GetIsRoot: Boolean;
  begin
    Lock;
    try
      Result := Parent = nil;
    finally
      Unlock;
    end;
  end;

  function TLKTreeNode<T>.GetIsBranch: Boolean;
  begin
    Lock;
    try
      Result := (not GetIsRoot) and (not GetIsLeaf);
    finally
      Unlock;
    end;
  end;

  function TLKTreeNode<T>.GetIsLeaf: Boolean;
  begin
    Lock;
    try
      Result := FChildren.Count = 0;
    finally
      Unlock;
    end;
  end;

  function TLKTreeNode<T>.GetDepth: Integer;
  var
    Ancestor: TLKTreeNode<T>;
  begin
    Lock;
    try
      Ancestor := Parent;
      Result := 0;

      while Ancestor <> nil do
      begin
        Inc(Result);
        Ancestor := Ancestor.Parent;
      end;
    finally
      Unlock;
    end;
  end;

  procedure TLKTreeNode<T>.Destroying;
  begin
    FDestroying := True;
  end;

  procedure TLKTreeNode<T>.AddChild(const AIndex: Integer; const AChild: TLKTreeNode<T>);
  begin
    if AIndex < 0 then
      FChildren.Add(AChild)
    else
      FChildren.Insert(AChild, AIndex);
  end;

  procedure TLKTreeNode<T>.RemoveChild(const AChild: TLKTreeNode<T>);
  begin
    FChildren.Remove(AChild);
  end;

  procedure TLKTreeNode<T>.SetValue(const AValue: T);
  begin
    Lock;
    try
      FValue := AValue;
    finally
      Unlock;
    end;
  end;

  procedure TLKTreeNode<T>.AfterConstruction;
  begin
    inherited;

    if Parent <> nil then
      Parent.AddChild(-1, Self);

    DoAncestorChanged;
  end;

  procedure TLKTreeNode<T>.AncestorChanged;
  begin
    // Do nothing (yet)
  end;

  procedure TLKTreeNode<T>.BeforeDestruction;
  begin
    inherited;

    if not IsDestroying then
      PreOrderWalk(procedure(const Node: TLKTreeNode<T>)
                   begin
                     Node.Destroying;
                   end);

    if (Parent <> nil) and (not Parent.IsDestroying) then
      Parent.RemoveChild(Self);
  end;

  procedure TLKTreeNode<T>.MoveTo(const ANewParent: TLKTreeNode<T>; const AIndex: Integer = -1);
  begin
    if (Parent = nil) and (ANewParent = nil) then
      Exit;

    Lock;
    try
      if Parent = ANewParent then
      begin
        if AIndex <> IndexAsChild then
        begin
          Parent.FChildren.Remove(Self);
          if AIndex < 0 then
            Parent.FChildren.Add(Self)
          else
            Parent.FChildren.Insert(Self, AIndex);
        end;
      end else
      begin
        if Parent <> nil then
          Parent.RemoveChild(Self);

        FParent := ANewParent;

        if Parent <> nil then
          Parent.AddChild(AIndex, Self);

        DoAncestorChanged;
      end;
    finally
      Unlock;
    end;
  end;

  procedure TLKTreeNode<T>.MoveTo(const AIndex: Integer);
  begin
    MoveTo(Parent, AIndex);
  end;

  function TLKTreeNode<T>.IndexOf(const AChild: TLKTreeNode<T>): Integer;
  begin
    Lock;
    try
      Result := FChildren.IndexOf(AChild);
    finally
      Unlock;
    end;
  end;

  procedure TLKTreeNode<T>.PreOrderWalk(const AAction: TLKValueCallback<TLKTreeNode<T>>);
  var
    Index: Integer;
  begin
    Lock;
    try
      AAction(Self);
      for Index := 0 to ChildCount-1 do
        Children[Index].PreOrderWalk(AAction);
    finally
      Unlock;
    end;
  end;

  procedure TLKTreeNode<T>.PreOrderWalk(const AAction: TLKValueCallback<T>);
  begin
    Lock;
    try
      PreOrderWalk(procedure(const Node: TLKTreeNode<T>)
                   begin
                     AAction(Node.Value);
                   end);
    finally
      Unlock;
    end;
  end;

  procedure TLKTreeNode<T>.PostOrderWalk(const AAction: TLKValueCallback<TLKTreeNode<T>>);
  var
    LIndex: Integer;
  begin
    Lock;
    try
      for LIndex := 0 to ChildCount-1 do
        Children[LIndex].PostOrderWalk(AAction);
      AAction(Self);
    finally
      Unlock;
    end;
  end;

  procedure TLKTreeNode<T>.PostOrderWalk(const AAction: TLKValueCallback<T>);
  begin
    Lock;
    try
      PostOrderWalk(procedure(const Node: TLKTreeNode<T>)
                    begin
                      AAction(Node.Value);
                    end);
    finally
      Unlock;
    end;
  end;

  { TLKTreeObjectNode<T> }

  constructor TLKTreeObjectNode<T>.Create;
  begin
    inherited;
    FOwnsObject := True;
  end;

  constructor TLKTreeObjectNode<T>.Create(const AParent: TLKTreeNode<T>; const AValue: T);
  begin
    inherited;
    FOwnsObject := True;
  end;

  constructor TLKTreeObjectNode<T>.Create(const AParent: TLKTreeNode<T>);
  begin
    inherited;
    FOwnsObject := True;
  end;

  constructor TLKTreeObjectNode<T>.Create(const AValue: T);
  begin
    inherited;
    FOwnsObject := True;
  end;

  destructor TLKTreeObjectNode<T>.Destroy;
  begin
    if FOwnsObject then
      FValue.DisposeOf;
    inherited;
  end;
{$ENDIF FPC}

end.

