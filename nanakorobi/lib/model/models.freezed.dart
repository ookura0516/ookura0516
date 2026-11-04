// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Daruma {

 int get id;/// 腹に入る文字（2〜6字）。
 String get name; DarumaColor get color; EyeSide get eyeSide;/// 開眼した日。
 LocalDate get createdOn;/// 本番の日（任意）。
 LocalDate? get deadline;/// 本番の名前（「共通テスト」など。ウィジェットの見出し）。
 String? get deadlineLabel;/// 毎日の一歩（任意）。
 String? get dailyAction; DarumaStatus get status; LocalDate? get completedOn; LocalDate? get retiredOn;/// 大きさの段階。ひと回り大きいだるまで +1。
 int get sizeRank;/// やり直し元のだるま。
 int? get parentId;/// 眉とひげの揺らぎの種。
 int get seed;
/// Create a copy of Daruma
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DarumaCopyWith<Daruma> get copyWith => _$DarumaCopyWithImpl<Daruma>(this as Daruma, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Daruma;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Daruma&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.color, _this.color) || other.color == _this.color)&&(identical(other.eyeSide, _this.eyeSide) || other.eyeSide == _this.eyeSide)&&(identical(other.createdOn, _this.createdOn) || other.createdOn == _this.createdOn)&&(identical(other.deadline, _this.deadline) || other.deadline == _this.deadline)&&(identical(other.deadlineLabel, _this.deadlineLabel) || other.deadlineLabel == _this.deadlineLabel)&&(identical(other.dailyAction, _this.dailyAction) || other.dailyAction == _this.dailyAction)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.completedOn, _this.completedOn) || other.completedOn == _this.completedOn)&&(identical(other.retiredOn, _this.retiredOn) || other.retiredOn == _this.retiredOn)&&(identical(other.sizeRank, _this.sizeRank) || other.sizeRank == _this.sizeRank)&&(identical(other.parentId, _this.parentId) || other.parentId == _this.parentId)&&(identical(other.seed, _this.seed) || other.seed == _this.seed));
}


@override
int get hashCode {
  final _this = this as Daruma;
  return Object.hash(runtimeType,_this.id,_this.name,_this.color,_this.eyeSide,_this.createdOn,_this.deadline,_this.deadlineLabel,_this.dailyAction,_this.status,_this.completedOn,_this.retiredOn,_this.sizeRank,_this.parentId,_this.seed);
}

@override
String toString() {
  final _this = this as Daruma;
  return 'Daruma(id: ${_this.id}, name: ${_this.name}, color: ${_this.color}, eyeSide: ${_this.eyeSide}, createdOn: ${_this.createdOn}, deadline: ${_this.deadline}, deadlineLabel: ${_this.deadlineLabel}, dailyAction: ${_this.dailyAction}, status: ${_this.status}, completedOn: ${_this.completedOn}, retiredOn: ${_this.retiredOn}, sizeRank: ${_this.sizeRank}, parentId: ${_this.parentId}, seed: ${_this.seed})';
}


}

/// @nodoc
abstract mixin class $DarumaCopyWith<$Res>  {
  factory $DarumaCopyWith(Daruma value, $Res Function(Daruma) _then) = _$DarumaCopyWithImpl;
@useResult
$Res call({
 int id, String name, DarumaColor color, EyeSide eyeSide, LocalDate createdOn, LocalDate? deadline, String? deadlineLabel, String? dailyAction, DarumaStatus status, LocalDate? completedOn, LocalDate? retiredOn, int sizeRank, int? parentId, int seed
});




}
/// @nodoc
class _$DarumaCopyWithImpl<$Res>
    implements $DarumaCopyWith<$Res> {
  _$DarumaCopyWithImpl(this._self, this._then);

  final Daruma _self;
  final $Res Function(Daruma) _then;

/// Create a copy of Daruma
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? color = null,Object? eyeSide = null,Object? createdOn = null,Object? deadline = freezed,Object? deadlineLabel = freezed,Object? dailyAction = freezed,Object? status = null,Object? completedOn = freezed,Object? retiredOn = freezed,Object? sizeRank = null,Object? parentId = freezed,Object? seed = null,}) {
  return _then(Daruma(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as DarumaColor,eyeSide: null == eyeSide ? _self.eyeSide : eyeSide // ignore: cast_nullable_to_non_nullable
as EyeSide,createdOn: null == createdOn ? _self.createdOn : createdOn // ignore: cast_nullable_to_non_nullable
as LocalDate,deadline: freezed == deadline ? _self.deadline : deadline // ignore: cast_nullable_to_non_nullable
as LocalDate?,deadlineLabel: freezed == deadlineLabel ? _self.deadlineLabel : deadlineLabel // ignore: cast_nullable_to_non_nullable
as String?,dailyAction: freezed == dailyAction ? _self.dailyAction : dailyAction // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DarumaStatus,completedOn: freezed == completedOn ? _self.completedOn : completedOn // ignore: cast_nullable_to_non_nullable
as LocalDate?,retiredOn: freezed == retiredOn ? _self.retiredOn : retiredOn // ignore: cast_nullable_to_non_nullable
as LocalDate?,sizeRank: null == sizeRank ? _self.sizeRank : sizeRank // ignore: cast_nullable_to_non_nullable
as int,parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as int?,seed: null == seed ? _self.seed : seed // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [Daruma].
extension DarumaPatterns on Daruma {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Daruma value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Daruma() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Daruma value)  $default,){
final _that = this;
switch (_that) {
case _Daruma():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Daruma value)?  $default,){
final _that = this;
switch (_that) {
case _Daruma() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  DarumaColor color,  EyeSide eyeSide,  LocalDate createdOn,  LocalDate? deadline,  String? deadlineLabel,  String? dailyAction,  DarumaStatus status,  LocalDate? completedOn,  LocalDate? retiredOn,  int sizeRank,  int? parentId,  int seed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Daruma() when $default != null:
return $default(_that.id,_that.name,_that.color,_that.eyeSide,_that.createdOn,_that.deadline,_that.deadlineLabel,_that.dailyAction,_that.status,_that.completedOn,_that.retiredOn,_that.sizeRank,_that.parentId,_that.seed);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  DarumaColor color,  EyeSide eyeSide,  LocalDate createdOn,  LocalDate? deadline,  String? deadlineLabel,  String? dailyAction,  DarumaStatus status,  LocalDate? completedOn,  LocalDate? retiredOn,  int sizeRank,  int? parentId,  int seed)  $default,) {final _that = this;
switch (_that) {
case _Daruma():
return $default(_that.id,_that.name,_that.color,_that.eyeSide,_that.createdOn,_that.deadline,_that.deadlineLabel,_that.dailyAction,_that.status,_that.completedOn,_that.retiredOn,_that.sizeRank,_that.parentId,_that.seed);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  DarumaColor color,  EyeSide eyeSide,  LocalDate createdOn,  LocalDate? deadline,  String? deadlineLabel,  String? dailyAction,  DarumaStatus status,  LocalDate? completedOn,  LocalDate? retiredOn,  int sizeRank,  int? parentId,  int seed)?  $default,) {final _that = this;
switch (_that) {
case _Daruma() when $default != null:
return $default(_that.id,_that.name,_that.color,_that.eyeSide,_that.createdOn,_that.deadline,_that.deadlineLabel,_that.dailyAction,_that.status,_that.completedOn,_that.retiredOn,_that.sizeRank,_that.parentId,_that.seed);case _:
  return null;

}
}

}

/// @nodoc


class _Daruma extends Daruma {
  const _Daruma({required this.id, required this.name, required this.color, required this.eyeSide, required this.createdOn, this.deadline, this.deadlineLabel, this.dailyAction, this.status = DarumaStatus.active, this.completedOn, this.retiredOn, this.sizeRank = 1, this.parentId, this.seed = 0}): super._();
  

@override final  int id;
/// 腹に入る文字（2〜6字）。
@override final  String name;
@override final  DarumaColor color;
@override final  EyeSide eyeSide;
/// 開眼した日。
@override final  LocalDate createdOn;
/// 本番の日（任意）。
@override final  LocalDate? deadline;
/// 本番の名前（「共通テスト」など。ウィジェットの見出し）。
@override final  String? deadlineLabel;
/// 毎日の一歩（任意）。
@override final  String? dailyAction;
@override@JsonKey() final  DarumaStatus status;
@override final  LocalDate? completedOn;
@override final  LocalDate? retiredOn;
/// 大きさの段階。ひと回り大きいだるまで +1。
@override@JsonKey() final  int sizeRank;
/// やり直し元のだるま。
@override final  int? parentId;
/// 眉とひげの揺らぎの種。
@override@JsonKey() final  int seed;

/// Create a copy of Daruma
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DarumaCopyWith<_Daruma> get copyWith => __$DarumaCopyWithImpl<_Daruma>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Daruma&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.color, color) || other.color == color)&&(identical(other.eyeSide, eyeSide) || other.eyeSide == eyeSide)&&(identical(other.createdOn, createdOn) || other.createdOn == createdOn)&&(identical(other.deadline, deadline) || other.deadline == deadline)&&(identical(other.deadlineLabel, deadlineLabel) || other.deadlineLabel == deadlineLabel)&&(identical(other.dailyAction, dailyAction) || other.dailyAction == dailyAction)&&(identical(other.status, status) || other.status == status)&&(identical(other.completedOn, completedOn) || other.completedOn == completedOn)&&(identical(other.retiredOn, retiredOn) || other.retiredOn == retiredOn)&&(identical(other.sizeRank, sizeRank) || other.sizeRank == sizeRank)&&(identical(other.parentId, parentId) || other.parentId == parentId)&&(identical(other.seed, seed) || other.seed == seed));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,name,color,eyeSide,createdOn,deadline,deadlineLabel,dailyAction,status,completedOn,retiredOn,sizeRank,parentId,seed);
}

@override
String toString() {
    return 'Daruma(id: $id, name: $name, color: $color, eyeSide: $eyeSide, createdOn: $createdOn, deadline: $deadline, deadlineLabel: $deadlineLabel, dailyAction: $dailyAction, status: $status, completedOn: $completedOn, retiredOn: $retiredOn, sizeRank: $sizeRank, parentId: $parentId, seed: $seed)';
}


}

/// @nodoc
abstract mixin class _$DarumaCopyWith<$Res> implements $DarumaCopyWith<$Res> {
  factory _$DarumaCopyWith(_Daruma value, $Res Function(_Daruma) _then) = __$DarumaCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, DarumaColor color, EyeSide eyeSide, LocalDate createdOn, LocalDate? deadline, String? deadlineLabel, String? dailyAction, DarumaStatus status, LocalDate? completedOn, LocalDate? retiredOn, int sizeRank, int? parentId, int seed
});




}
/// @nodoc
class __$DarumaCopyWithImpl<$Res>
    implements _$DarumaCopyWith<$Res> {
  __$DarumaCopyWithImpl(this._self, this._then);

  final _Daruma _self;
  final $Res Function(_Daruma) _then;

/// Create a copy of Daruma
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? color = null,Object? eyeSide = null,Object? createdOn = null,Object? deadline = freezed,Object? deadlineLabel = freezed,Object? dailyAction = freezed,Object? status = null,Object? completedOn = freezed,Object? retiredOn = freezed,Object? sizeRank = null,Object? parentId = freezed,Object? seed = null,}) {
  return _then(_Daruma(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as DarumaColor,eyeSide: null == eyeSide ? _self.eyeSide : eyeSide // ignore: cast_nullable_to_non_nullable
as EyeSide,createdOn: null == createdOn ? _self.createdOn : createdOn // ignore: cast_nullable_to_non_nullable
as LocalDate,deadline: freezed == deadline ? _self.deadline : deadline // ignore: cast_nullable_to_non_nullable
as LocalDate?,deadlineLabel: freezed == deadlineLabel ? _self.deadlineLabel : deadlineLabel // ignore: cast_nullable_to_non_nullable
as String?,dailyAction: freezed == dailyAction ? _self.dailyAction : dailyAction // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DarumaStatus,completedOn: freezed == completedOn ? _self.completedOn : completedOn // ignore: cast_nullable_to_non_nullable
as LocalDate?,retiredOn: freezed == retiredOn ? _self.retiredOn : retiredOn // ignore: cast_nullable_to_non_nullable
as LocalDate?,sizeRank: null == sizeRank ? _self.sizeRank : sizeRank // ignore: cast_nullable_to_non_nullable
as int,parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as int?,seed: null == seed ? _self.seed : seed // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$Checkin {

 int get id; int get darumaId; LocalDate get date; CheckinKind get kind; String? get memo;
/// Create a copy of Checkin
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CheckinCopyWith<Checkin> get copyWith => _$CheckinCopyWithImpl<Checkin>(this as Checkin, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Checkin;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Checkin&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.darumaId, _this.darumaId) || other.darumaId == _this.darumaId)&&(identical(other.date, _this.date) || other.date == _this.date)&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.memo, _this.memo) || other.memo == _this.memo));
}


@override
int get hashCode {
  final _this = this as Checkin;
  return Object.hash(runtimeType,_this.id,_this.darumaId,_this.date,_this.kind,_this.memo);
}

@override
String toString() {
  final _this = this as Checkin;
  return 'Checkin(id: ${_this.id}, darumaId: ${_this.darumaId}, date: ${_this.date}, kind: ${_this.kind}, memo: ${_this.memo})';
}


}

/// @nodoc
abstract mixin class $CheckinCopyWith<$Res>  {
  factory $CheckinCopyWith(Checkin value, $Res Function(Checkin) _then) = _$CheckinCopyWithImpl;
@useResult
$Res call({
 int id, int darumaId, LocalDate date, CheckinKind kind, String? memo
});




}
/// @nodoc
class _$CheckinCopyWithImpl<$Res>
    implements $CheckinCopyWith<$Res> {
  _$CheckinCopyWithImpl(this._self, this._then);

  final Checkin _self;
  final $Res Function(Checkin) _then;

/// Create a copy of Checkin
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? darumaId = null,Object? date = null,Object? kind = null,Object? memo = freezed,}) {
  return _then(Checkin(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,darumaId: null == darumaId ? _self.darumaId : darumaId // ignore: cast_nullable_to_non_nullable
as int,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as LocalDate,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as CheckinKind,memo: freezed == memo ? _self.memo : memo // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Checkin].
extension CheckinPatterns on Checkin {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Checkin value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Checkin() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Checkin value)  $default,){
final _that = this;
switch (_that) {
case _Checkin():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Checkin value)?  $default,){
final _that = this;
switch (_that) {
case _Checkin() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int darumaId,  LocalDate date,  CheckinKind kind,  String? memo)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Checkin() when $default != null:
return $default(_that.id,_that.darumaId,_that.date,_that.kind,_that.memo);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int darumaId,  LocalDate date,  CheckinKind kind,  String? memo)  $default,) {final _that = this;
switch (_that) {
case _Checkin():
return $default(_that.id,_that.darumaId,_that.date,_that.kind,_that.memo);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int darumaId,  LocalDate date,  CheckinKind kind,  String? memo)?  $default,) {final _that = this;
switch (_that) {
case _Checkin() when $default != null:
return $default(_that.id,_that.darumaId,_that.date,_that.kind,_that.memo);case _:
  return null;

}
}

}

/// @nodoc


class _Checkin implements Checkin {
  const _Checkin({required this.id, required this.darumaId, required this.date, this.kind = CheckinKind.step, this.memo});
  

@override final  int id;
@override final  int darumaId;
@override final  LocalDate date;
@override@JsonKey() final  CheckinKind kind;
@override final  String? memo;

/// Create a copy of Checkin
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CheckinCopyWith<_Checkin> get copyWith => __$CheckinCopyWithImpl<_Checkin>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Checkin&&(identical(other.id, id) || other.id == id)&&(identical(other.darumaId, darumaId) || other.darumaId == darumaId)&&(identical(other.date, date) || other.date == date)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.memo, memo) || other.memo == memo));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,darumaId,date,kind,memo);
}

@override
String toString() {
    return 'Checkin(id: $id, darumaId: $darumaId, date: $date, kind: $kind, memo: $memo)';
}


}

/// @nodoc
abstract mixin class _$CheckinCopyWith<$Res> implements $CheckinCopyWith<$Res> {
  factory _$CheckinCopyWith(_Checkin value, $Res Function(_Checkin) _then) = __$CheckinCopyWithImpl;
@override @useResult
$Res call({
 int id, int darumaId, LocalDate date, CheckinKind kind, String? memo
});




}
/// @nodoc
class __$CheckinCopyWithImpl<$Res>
    implements _$CheckinCopyWith<$Res> {
  __$CheckinCopyWithImpl(this._self, this._then);

  final _Checkin _self;
  final $Res Function(_Checkin) _then;

/// Create a copy of Checkin
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? darumaId = null,Object? date = null,Object? kind = null,Object? memo = freezed,}) {
  return _then(_Checkin(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,darumaId: null == darumaId ? _self.darumaId : darumaId // ignore: cast_nullable_to_non_nullable
as int,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as LocalDate,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as CheckinKind,memo: freezed == memo ? _self.memo : memo // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$Recovery {

 int get id; int get darumaId;/// 最後に記録した日（転ぶ前）。
 LocalDate get fellAfter;/// 起き上がった日。
 LocalDate get roseOn;
/// Create a copy of Recovery
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecoveryCopyWith<Recovery> get copyWith => _$RecoveryCopyWithImpl<Recovery>(this as Recovery, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Recovery;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Recovery&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.darumaId, _this.darumaId) || other.darumaId == _this.darumaId)&&(identical(other.fellAfter, _this.fellAfter) || other.fellAfter == _this.fellAfter)&&(identical(other.roseOn, _this.roseOn) || other.roseOn == _this.roseOn));
}


@override
int get hashCode {
  final _this = this as Recovery;
  return Object.hash(runtimeType,_this.id,_this.darumaId,_this.fellAfter,_this.roseOn);
}

@override
String toString() {
  final _this = this as Recovery;
  return 'Recovery(id: ${_this.id}, darumaId: ${_this.darumaId}, fellAfter: ${_this.fellAfter}, roseOn: ${_this.roseOn})';
}


}

/// @nodoc
abstract mixin class $RecoveryCopyWith<$Res>  {
  factory $RecoveryCopyWith(Recovery value, $Res Function(Recovery) _then) = _$RecoveryCopyWithImpl;
@useResult
$Res call({
 int id, int darumaId, LocalDate fellAfter, LocalDate roseOn
});




}
/// @nodoc
class _$RecoveryCopyWithImpl<$Res>
    implements $RecoveryCopyWith<$Res> {
  _$RecoveryCopyWithImpl(this._self, this._then);

  final Recovery _self;
  final $Res Function(Recovery) _then;

/// Create a copy of Recovery
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? darumaId = null,Object? fellAfter = null,Object? roseOn = null,}) {
  return _then(Recovery(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,darumaId: null == darumaId ? _self.darumaId : darumaId // ignore: cast_nullable_to_non_nullable
as int,fellAfter: null == fellAfter ? _self.fellAfter : fellAfter // ignore: cast_nullable_to_non_nullable
as LocalDate,roseOn: null == roseOn ? _self.roseOn : roseOn // ignore: cast_nullable_to_non_nullable
as LocalDate,
  ));
}

}


/// Adds pattern-matching-related methods to [Recovery].
extension RecoveryPatterns on Recovery {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Recovery value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Recovery() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Recovery value)  $default,){
final _that = this;
switch (_that) {
case _Recovery():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Recovery value)?  $default,){
final _that = this;
switch (_that) {
case _Recovery() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int darumaId,  LocalDate fellAfter,  LocalDate roseOn)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Recovery() when $default != null:
return $default(_that.id,_that.darumaId,_that.fellAfter,_that.roseOn);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int darumaId,  LocalDate fellAfter,  LocalDate roseOn)  $default,) {final _that = this;
switch (_that) {
case _Recovery():
return $default(_that.id,_that.darumaId,_that.fellAfter,_that.roseOn);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int darumaId,  LocalDate fellAfter,  LocalDate roseOn)?  $default,) {final _that = this;
switch (_that) {
case _Recovery() when $default != null:
return $default(_that.id,_that.darumaId,_that.fellAfter,_that.roseOn);case _:
  return null;

}
}

}

/// @nodoc


class _Recovery implements Recovery {
  const _Recovery({required this.id, required this.darumaId, required this.fellAfter, required this.roseOn});
  

@override final  int id;
@override final  int darumaId;
/// 最後に記録した日（転ぶ前）。
@override final  LocalDate fellAfter;
/// 起き上がった日。
@override final  LocalDate roseOn;

/// Create a copy of Recovery
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecoveryCopyWith<_Recovery> get copyWith => __$RecoveryCopyWithImpl<_Recovery>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Recovery&&(identical(other.id, id) || other.id == id)&&(identical(other.darumaId, darumaId) || other.darumaId == darumaId)&&(identical(other.fellAfter, fellAfter) || other.fellAfter == fellAfter)&&(identical(other.roseOn, roseOn) || other.roseOn == roseOn));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,darumaId,fellAfter,roseOn);
}

@override
String toString() {
    return 'Recovery(id: $id, darumaId: $darumaId, fellAfter: $fellAfter, roseOn: $roseOn)';
}


}

/// @nodoc
abstract mixin class _$RecoveryCopyWith<$Res> implements $RecoveryCopyWith<$Res> {
  factory _$RecoveryCopyWith(_Recovery value, $Res Function(_Recovery) _then) = __$RecoveryCopyWithImpl;
@override @useResult
$Res call({
 int id, int darumaId, LocalDate fellAfter, LocalDate roseOn
});




}
/// @nodoc
class __$RecoveryCopyWithImpl<$Res>
    implements _$RecoveryCopyWith<$Res> {
  __$RecoveryCopyWithImpl(this._self, this._then);

  final _Recovery _self;
  final $Res Function(_Recovery) _then;

/// Create a copy of Recovery
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? darumaId = null,Object? fellAfter = null,Object? roseOn = null,}) {
  return _then(_Recovery(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,darumaId: null == darumaId ? _self.darumaId : darumaId // ignore: cast_nullable_to_non_nullable
as int,fellAfter: null == fellAfter ? _self.fellAfter : fellAfter // ignore: cast_nullable_to_non_nullable
as LocalDate,roseOn: null == roseOn ? _self.roseOn : roseOn // ignore: cast_nullable_to_non_nullable
as LocalDate,
  ));
}


}

/// @nodoc
mixin _$NewDaruma {

 String get name; DarumaColor get color; EyeSide get eyeSide; LocalDate? get deadline; String? get deadlineLabel; String? get dailyAction; int? get parentId; int get sizeRank;
/// Create a copy of NewDaruma
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NewDarumaCopyWith<NewDaruma> get copyWith => _$NewDarumaCopyWithImpl<NewDaruma>(this as NewDaruma, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as NewDaruma;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NewDaruma&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.color, _this.color) || other.color == _this.color)&&(identical(other.eyeSide, _this.eyeSide) || other.eyeSide == _this.eyeSide)&&(identical(other.deadline, _this.deadline) || other.deadline == _this.deadline)&&(identical(other.deadlineLabel, _this.deadlineLabel) || other.deadlineLabel == _this.deadlineLabel)&&(identical(other.dailyAction, _this.dailyAction) || other.dailyAction == _this.dailyAction)&&(identical(other.parentId, _this.parentId) || other.parentId == _this.parentId)&&(identical(other.sizeRank, _this.sizeRank) || other.sizeRank == _this.sizeRank));
}


@override
int get hashCode {
  final _this = this as NewDaruma;
  return Object.hash(runtimeType,_this.name,_this.color,_this.eyeSide,_this.deadline,_this.deadlineLabel,_this.dailyAction,_this.parentId,_this.sizeRank);
}

@override
String toString() {
  final _this = this as NewDaruma;
  return 'NewDaruma(name: ${_this.name}, color: ${_this.color}, eyeSide: ${_this.eyeSide}, deadline: ${_this.deadline}, deadlineLabel: ${_this.deadlineLabel}, dailyAction: ${_this.dailyAction}, parentId: ${_this.parentId}, sizeRank: ${_this.sizeRank})';
}


}

/// @nodoc
abstract mixin class $NewDarumaCopyWith<$Res>  {
  factory $NewDarumaCopyWith(NewDaruma value, $Res Function(NewDaruma) _then) = _$NewDarumaCopyWithImpl;
@useResult
$Res call({
 String name, DarumaColor color, EyeSide eyeSide, LocalDate? deadline, String? deadlineLabel, String? dailyAction, int? parentId, int sizeRank
});




}
/// @nodoc
class _$NewDarumaCopyWithImpl<$Res>
    implements $NewDarumaCopyWith<$Res> {
  _$NewDarumaCopyWithImpl(this._self, this._then);

  final NewDaruma _self;
  final $Res Function(NewDaruma) _then;

/// Create a copy of NewDaruma
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? color = null,Object? eyeSide = null,Object? deadline = freezed,Object? deadlineLabel = freezed,Object? dailyAction = freezed,Object? parentId = freezed,Object? sizeRank = null,}) {
  return _then(NewDaruma(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as DarumaColor,eyeSide: null == eyeSide ? _self.eyeSide : eyeSide // ignore: cast_nullable_to_non_nullable
as EyeSide,deadline: freezed == deadline ? _self.deadline : deadline // ignore: cast_nullable_to_non_nullable
as LocalDate?,deadlineLabel: freezed == deadlineLabel ? _self.deadlineLabel : deadlineLabel // ignore: cast_nullable_to_non_nullable
as String?,dailyAction: freezed == dailyAction ? _self.dailyAction : dailyAction // ignore: cast_nullable_to_non_nullable
as String?,parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as int?,sizeRank: null == sizeRank ? _self.sizeRank : sizeRank // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [NewDaruma].
extension NewDarumaPatterns on NewDaruma {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NewDaruma value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NewDaruma() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NewDaruma value)  $default,){
final _that = this;
switch (_that) {
case _NewDaruma():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NewDaruma value)?  $default,){
final _that = this;
switch (_that) {
case _NewDaruma() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  DarumaColor color,  EyeSide eyeSide,  LocalDate? deadline,  String? deadlineLabel,  String? dailyAction,  int? parentId,  int sizeRank)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NewDaruma() when $default != null:
return $default(_that.name,_that.color,_that.eyeSide,_that.deadline,_that.deadlineLabel,_that.dailyAction,_that.parentId,_that.sizeRank);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  DarumaColor color,  EyeSide eyeSide,  LocalDate? deadline,  String? deadlineLabel,  String? dailyAction,  int? parentId,  int sizeRank)  $default,) {final _that = this;
switch (_that) {
case _NewDaruma():
return $default(_that.name,_that.color,_that.eyeSide,_that.deadline,_that.deadlineLabel,_that.dailyAction,_that.parentId,_that.sizeRank);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  DarumaColor color,  EyeSide eyeSide,  LocalDate? deadline,  String? deadlineLabel,  String? dailyAction,  int? parentId,  int sizeRank)?  $default,) {final _that = this;
switch (_that) {
case _NewDaruma() when $default != null:
return $default(_that.name,_that.color,_that.eyeSide,_that.deadline,_that.deadlineLabel,_that.dailyAction,_that.parentId,_that.sizeRank);case _:
  return null;

}
}

}

/// @nodoc


class _NewDaruma implements NewDaruma {
  const _NewDaruma({required this.name, required this.color, required this.eyeSide, this.deadline, this.deadlineLabel, this.dailyAction, this.parentId, this.sizeRank = 1});
  

@override final  String name;
@override final  DarumaColor color;
@override final  EyeSide eyeSide;
@override final  LocalDate? deadline;
@override final  String? deadlineLabel;
@override final  String? dailyAction;
@override final  int? parentId;
@override@JsonKey() final  int sizeRank;

/// Create a copy of NewDaruma
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NewDarumaCopyWith<_NewDaruma> get copyWith => __$NewDarumaCopyWithImpl<_NewDaruma>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _NewDaruma&&(identical(other.name, name) || other.name == name)&&(identical(other.color, color) || other.color == color)&&(identical(other.eyeSide, eyeSide) || other.eyeSide == eyeSide)&&(identical(other.deadline, deadline) || other.deadline == deadline)&&(identical(other.deadlineLabel, deadlineLabel) || other.deadlineLabel == deadlineLabel)&&(identical(other.dailyAction, dailyAction) || other.dailyAction == dailyAction)&&(identical(other.parentId, parentId) || other.parentId == parentId)&&(identical(other.sizeRank, sizeRank) || other.sizeRank == sizeRank));
}


@override
int get hashCode {
    return Object.hash(runtimeType,name,color,eyeSide,deadline,deadlineLabel,dailyAction,parentId,sizeRank);
}

@override
String toString() {
    return 'NewDaruma(name: $name, color: $color, eyeSide: $eyeSide, deadline: $deadline, deadlineLabel: $deadlineLabel, dailyAction: $dailyAction, parentId: $parentId, sizeRank: $sizeRank)';
}


}

/// @nodoc
abstract mixin class _$NewDarumaCopyWith<$Res> implements $NewDarumaCopyWith<$Res> {
  factory _$NewDarumaCopyWith(_NewDaruma value, $Res Function(_NewDaruma) _then) = __$NewDarumaCopyWithImpl;
@override @useResult
$Res call({
 String name, DarumaColor color, EyeSide eyeSide, LocalDate? deadline, String? deadlineLabel, String? dailyAction, int? parentId, int sizeRank
});




}
/// @nodoc
class __$NewDarumaCopyWithImpl<$Res>
    implements _$NewDarumaCopyWith<$Res> {
  __$NewDarumaCopyWithImpl(this._self, this._then);

  final _NewDaruma _self;
  final $Res Function(_NewDaruma) _then;

/// Create a copy of NewDaruma
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? color = null,Object? eyeSide = null,Object? deadline = freezed,Object? deadlineLabel = freezed,Object? dailyAction = freezed,Object? parentId = freezed,Object? sizeRank = null,}) {
  return _then(_NewDaruma(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as DarumaColor,eyeSide: null == eyeSide ? _self.eyeSide : eyeSide // ignore: cast_nullable_to_non_nullable
as EyeSide,deadline: freezed == deadline ? _self.deadline : deadline // ignore: cast_nullable_to_non_nullable
as LocalDate?,deadlineLabel: freezed == deadlineLabel ? _self.deadlineLabel : deadlineLabel // ignore: cast_nullable_to_non_nullable
as String?,dailyAction: freezed == dailyAction ? _self.dailyAction : dailyAction // ignore: cast_nullable_to_non_nullable
as String?,parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as int?,sizeRank: null == sizeRank ? _self.sizeRank : sizeRank // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$DarumaDetail {

 Daruma get daruma; List<Checkin> get checkins; List<Recovery> get recoveries;
/// Create a copy of DarumaDetail
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DarumaDetailCopyWith<DarumaDetail> get copyWith => _$DarumaDetailCopyWithImpl<DarumaDetail>(this as DarumaDetail, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as DarumaDetail;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DarumaDetail&&(identical(other.daruma, _this.daruma) || other.daruma == _this.daruma)&&const DeepCollectionEquality().equals(other.checkins, _this.checkins)&&const DeepCollectionEquality().equals(other.recoveries, _this.recoveries));
}


@override
int get hashCode {
  final _this = this as DarumaDetail;
  return Object.hash(runtimeType,_this.daruma,const DeepCollectionEquality().hash(_this.checkins),const DeepCollectionEquality().hash(_this.recoveries));
}

@override
String toString() {
  final _this = this as DarumaDetail;
  return 'DarumaDetail(daruma: ${_this.daruma}, checkins: ${_this.checkins}, recoveries: ${_this.recoveries})';
}


}

/// @nodoc
abstract mixin class $DarumaDetailCopyWith<$Res>  {
  factory $DarumaDetailCopyWith(DarumaDetail value, $Res Function(DarumaDetail) _then) = _$DarumaDetailCopyWithImpl;
@useResult
$Res call({
 Daruma daruma, List<Checkin> checkins, List<Recovery> recoveries
});


$DarumaCopyWith<$Res> get daruma;

}
/// @nodoc
class _$DarumaDetailCopyWithImpl<$Res>
    implements $DarumaDetailCopyWith<$Res> {
  _$DarumaDetailCopyWithImpl(this._self, this._then);

  final DarumaDetail _self;
  final $Res Function(DarumaDetail) _then;

/// Create a copy of DarumaDetail
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? daruma = null,Object? checkins = null,Object? recoveries = null,}) {
  return _then(DarumaDetail(
daruma: null == daruma ? _self.daruma : daruma // ignore: cast_nullable_to_non_nullable
as Daruma,checkins: null == checkins ? _self.checkins : checkins // ignore: cast_nullable_to_non_nullable
as List<Checkin>,recoveries: null == recoveries ? _self.recoveries : recoveries // ignore: cast_nullable_to_non_nullable
as List<Recovery>,
  ));
}
/// Create a copy of DarumaDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DarumaCopyWith<$Res> get daruma {
  
  return $DarumaCopyWith<$Res>(_self.daruma, (value) {
    return _then(_self.copyWith(daruma: value));
  });
}
}


/// Adds pattern-matching-related methods to [DarumaDetail].
extension DarumaDetailPatterns on DarumaDetail {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DarumaDetail value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DarumaDetail() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DarumaDetail value)  $default,){
final _that = this;
switch (_that) {
case _DarumaDetail():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DarumaDetail value)?  $default,){
final _that = this;
switch (_that) {
case _DarumaDetail() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Daruma daruma,  List<Checkin> checkins,  List<Recovery> recoveries)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DarumaDetail() when $default != null:
return $default(_that.daruma,_that.checkins,_that.recoveries);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Daruma daruma,  List<Checkin> checkins,  List<Recovery> recoveries)  $default,) {final _that = this;
switch (_that) {
case _DarumaDetail():
return $default(_that.daruma,_that.checkins,_that.recoveries);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Daruma daruma,  List<Checkin> checkins,  List<Recovery> recoveries)?  $default,) {final _that = this;
switch (_that) {
case _DarumaDetail() when $default != null:
return $default(_that.daruma,_that.checkins,_that.recoveries);case _:
  return null;

}
}

}

/// @nodoc


class _DarumaDetail extends DarumaDetail {
  const _DarumaDetail({required this.daruma, required  List<Checkin> checkins, required  List<Recovery> recoveries}): _checkins = checkins,_recoveries = recoveries,super._();
  

@override final  Daruma daruma;
 final  List<Checkin> _checkins;
@override List<Checkin> get checkins {
  if (_checkins is EqualUnmodifiableListView) return _checkins;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_checkins);
}

 final  List<Recovery> _recoveries;
@override List<Recovery> get recoveries {
  if (_recoveries is EqualUnmodifiableListView) return _recoveries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_recoveries);
}


/// Create a copy of DarumaDetail
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DarumaDetailCopyWith<_DarumaDetail> get copyWith => __$DarumaDetailCopyWithImpl<_DarumaDetail>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DarumaDetail&&(identical(other.daruma, daruma) || other.daruma == daruma)&&const DeepCollectionEquality().equals(other.checkins, _checkins)&&const DeepCollectionEquality().equals(other.recoveries, _recoveries));
}


@override
int get hashCode {
    return Object.hash(runtimeType,daruma,const DeepCollectionEquality().hash(_checkins),const DeepCollectionEquality().hash(_recoveries));
}

@override
String toString() {
    return 'DarumaDetail(daruma: $daruma, checkins: $checkins, recoveries: $recoveries)';
}


}

/// @nodoc
abstract mixin class _$DarumaDetailCopyWith<$Res> implements $DarumaDetailCopyWith<$Res> {
  factory _$DarumaDetailCopyWith(_DarumaDetail value, $Res Function(_DarumaDetail) _then) = __$DarumaDetailCopyWithImpl;
@override @useResult
$Res call({
 Daruma daruma, List<Checkin> checkins, List<Recovery> recoveries
});


@override $DarumaCopyWith<$Res> get daruma;

}
/// @nodoc
class __$DarumaDetailCopyWithImpl<$Res>
    implements _$DarumaDetailCopyWith<$Res> {
  __$DarumaDetailCopyWithImpl(this._self, this._then);

  final _DarumaDetail _self;
  final $Res Function(_DarumaDetail) _then;

/// Create a copy of DarumaDetail
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? daruma = null,Object? checkins = null,Object? recoveries = null,}) {
  return _then(_DarumaDetail(
daruma: null == daruma ? _self.daruma : daruma // ignore: cast_nullable_to_non_nullable
as Daruma,checkins: null == checkins ? _self._checkins : checkins // ignore: cast_nullable_to_non_nullable
as List<Checkin>,recoveries: null == recoveries ? _self._recoveries : recoveries // ignore: cast_nullable_to_non_nullable
as List<Recovery>,
  ));
}

/// Create a copy of DarumaDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DarumaCopyWith<$Res> get daruma {
  
  return $DarumaCopyWith<$Res>(_self.daruma, (value) {
    return _then(_self.copyWith(daruma: value));
  });
}
}

/// @nodoc
mixin _$DarumaLook {

 DarumaColor get color; String get text; int get brushCount; int get goldStripes;/// 入っている目の数。0＝まだ、1＝片目、2＝両目。
 int get openedEyes; EyeSide get eyeSide; int get sizeRank; bool get fallen; int get seed;
/// Create a copy of DarumaLook
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DarumaLookCopyWith<DarumaLook> get copyWith => _$DarumaLookCopyWithImpl<DarumaLook>(this as DarumaLook, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as DarumaLook;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DarumaLook&&(identical(other.color, _this.color) || other.color == _this.color)&&(identical(other.text, _this.text) || other.text == _this.text)&&(identical(other.brushCount, _this.brushCount) || other.brushCount == _this.brushCount)&&(identical(other.goldStripes, _this.goldStripes) || other.goldStripes == _this.goldStripes)&&(identical(other.openedEyes, _this.openedEyes) || other.openedEyes == _this.openedEyes)&&(identical(other.eyeSide, _this.eyeSide) || other.eyeSide == _this.eyeSide)&&(identical(other.sizeRank, _this.sizeRank) || other.sizeRank == _this.sizeRank)&&(identical(other.fallen, _this.fallen) || other.fallen == _this.fallen)&&(identical(other.seed, _this.seed) || other.seed == _this.seed));
}


@override
int get hashCode {
  final _this = this as DarumaLook;
  return Object.hash(runtimeType,_this.color,_this.text,_this.brushCount,_this.goldStripes,_this.openedEyes,_this.eyeSide,_this.sizeRank,_this.fallen,_this.seed);
}

@override
String toString() {
  final _this = this as DarumaLook;
  return 'DarumaLook(color: ${_this.color}, text: ${_this.text}, brushCount: ${_this.brushCount}, goldStripes: ${_this.goldStripes}, openedEyes: ${_this.openedEyes}, eyeSide: ${_this.eyeSide}, sizeRank: ${_this.sizeRank}, fallen: ${_this.fallen}, seed: ${_this.seed})';
}


}

/// @nodoc
abstract mixin class $DarumaLookCopyWith<$Res>  {
  factory $DarumaLookCopyWith(DarumaLook value, $Res Function(DarumaLook) _then) = _$DarumaLookCopyWithImpl;
@useResult
$Res call({
 DarumaColor color, String text, int brushCount, int goldStripes, int openedEyes, EyeSide eyeSide, int sizeRank, bool fallen, int seed
});




}
/// @nodoc
class _$DarumaLookCopyWithImpl<$Res>
    implements $DarumaLookCopyWith<$Res> {
  _$DarumaLookCopyWithImpl(this._self, this._then);

  final DarumaLook _self;
  final $Res Function(DarumaLook) _then;

/// Create a copy of DarumaLook
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? color = null,Object? text = null,Object? brushCount = null,Object? goldStripes = null,Object? openedEyes = null,Object? eyeSide = null,Object? sizeRank = null,Object? fallen = null,Object? seed = null,}) {
  return _then(DarumaLook(
color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as DarumaColor,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,brushCount: null == brushCount ? _self.brushCount : brushCount // ignore: cast_nullable_to_non_nullable
as int,goldStripes: null == goldStripes ? _self.goldStripes : goldStripes // ignore: cast_nullable_to_non_nullable
as int,openedEyes: null == openedEyes ? _self.openedEyes : openedEyes // ignore: cast_nullable_to_non_nullable
as int,eyeSide: null == eyeSide ? _self.eyeSide : eyeSide // ignore: cast_nullable_to_non_nullable
as EyeSide,sizeRank: null == sizeRank ? _self.sizeRank : sizeRank // ignore: cast_nullable_to_non_nullable
as int,fallen: null == fallen ? _self.fallen : fallen // ignore: cast_nullable_to_non_nullable
as bool,seed: null == seed ? _self.seed : seed // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [DarumaLook].
extension DarumaLookPatterns on DarumaLook {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DarumaLook value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DarumaLook() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DarumaLook value)  $default,){
final _that = this;
switch (_that) {
case _DarumaLook():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DarumaLook value)?  $default,){
final _that = this;
switch (_that) {
case _DarumaLook() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DarumaColor color,  String text,  int brushCount,  int goldStripes,  int openedEyes,  EyeSide eyeSide,  int sizeRank,  bool fallen,  int seed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DarumaLook() when $default != null:
return $default(_that.color,_that.text,_that.brushCount,_that.goldStripes,_that.openedEyes,_that.eyeSide,_that.sizeRank,_that.fallen,_that.seed);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DarumaColor color,  String text,  int brushCount,  int goldStripes,  int openedEyes,  EyeSide eyeSide,  int sizeRank,  bool fallen,  int seed)  $default,) {final _that = this;
switch (_that) {
case _DarumaLook():
return $default(_that.color,_that.text,_that.brushCount,_that.goldStripes,_that.openedEyes,_that.eyeSide,_that.sizeRank,_that.fallen,_that.seed);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DarumaColor color,  String text,  int brushCount,  int goldStripes,  int openedEyes,  EyeSide eyeSide,  int sizeRank,  bool fallen,  int seed)?  $default,) {final _that = this;
switch (_that) {
case _DarumaLook() when $default != null:
return $default(_that.color,_that.text,_that.brushCount,_that.goldStripes,_that.openedEyes,_that.eyeSide,_that.sizeRank,_that.fallen,_that.seed);case _:
  return null;

}
}

}

/// @nodoc


class _DarumaLook extends DarumaLook {
  const _DarumaLook({required this.color, required this.text, this.brushCount = 0, this.goldStripes = 0, this.openedEyes = 1, this.eyeSide = EyeSide.left, this.sizeRank = 1, this.fallen = false, this.seed = 0}): super._();
  

@override final  DarumaColor color;
@override final  String text;
@override@JsonKey() final  int brushCount;
@override@JsonKey() final  int goldStripes;
/// 入っている目の数。0＝まだ、1＝片目、2＝両目。
@override@JsonKey() final  int openedEyes;
@override@JsonKey() final  EyeSide eyeSide;
@override@JsonKey() final  int sizeRank;
@override@JsonKey() final  bool fallen;
@override@JsonKey() final  int seed;

/// Create a copy of DarumaLook
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DarumaLookCopyWith<_DarumaLook> get copyWith => __$DarumaLookCopyWithImpl<_DarumaLook>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DarumaLook&&(identical(other.color, color) || other.color == color)&&(identical(other.text, text) || other.text == text)&&(identical(other.brushCount, brushCount) || other.brushCount == brushCount)&&(identical(other.goldStripes, goldStripes) || other.goldStripes == goldStripes)&&(identical(other.openedEyes, openedEyes) || other.openedEyes == openedEyes)&&(identical(other.eyeSide, eyeSide) || other.eyeSide == eyeSide)&&(identical(other.sizeRank, sizeRank) || other.sizeRank == sizeRank)&&(identical(other.fallen, fallen) || other.fallen == fallen)&&(identical(other.seed, seed) || other.seed == seed));
}


@override
int get hashCode {
    return Object.hash(runtimeType,color,text,brushCount,goldStripes,openedEyes,eyeSide,sizeRank,fallen,seed);
}

@override
String toString() {
    return 'DarumaLook(color: $color, text: $text, brushCount: $brushCount, goldStripes: $goldStripes, openedEyes: $openedEyes, eyeSide: $eyeSide, sizeRank: $sizeRank, fallen: $fallen, seed: $seed)';
}


}

/// @nodoc
abstract mixin class _$DarumaLookCopyWith<$Res> implements $DarumaLookCopyWith<$Res> {
  factory _$DarumaLookCopyWith(_DarumaLook value, $Res Function(_DarumaLook) _then) = __$DarumaLookCopyWithImpl;
@override @useResult
$Res call({
 DarumaColor color, String text, int brushCount, int goldStripes, int openedEyes, EyeSide eyeSide, int sizeRank, bool fallen, int seed
});




}
/// @nodoc
class __$DarumaLookCopyWithImpl<$Res>
    implements _$DarumaLookCopyWith<$Res> {
  __$DarumaLookCopyWithImpl(this._self, this._then);

  final _DarumaLook _self;
  final $Res Function(_DarumaLook) _then;

/// Create a copy of DarumaLook
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? color = null,Object? text = null,Object? brushCount = null,Object? goldStripes = null,Object? openedEyes = null,Object? eyeSide = null,Object? sizeRank = null,Object? fallen = null,Object? seed = null,}) {
  return _then(_DarumaLook(
color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as DarumaColor,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,brushCount: null == brushCount ? _self.brushCount : brushCount // ignore: cast_nullable_to_non_nullable
as int,goldStripes: null == goldStripes ? _self.goldStripes : goldStripes // ignore: cast_nullable_to_non_nullable
as int,openedEyes: null == openedEyes ? _self.openedEyes : openedEyes // ignore: cast_nullable_to_non_nullable
as int,eyeSide: null == eyeSide ? _self.eyeSide : eyeSide // ignore: cast_nullable_to_non_nullable
as EyeSide,sizeRank: null == sizeRank ? _self.sizeRank : sizeRank // ignore: cast_nullable_to_non_nullable
as int,fallen: null == fallen ? _self.fallen : fallen // ignore: cast_nullable_to_non_nullable
as bool,seed: null == seed ? _self.seed : seed // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
