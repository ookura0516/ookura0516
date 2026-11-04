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

 String get id;/// 腹の文字（2〜6字）。
 String get name; int get colorId; EyeSide get eyeSide; DateTime get createdAt;/// 開眼日（端末のローカル日付）。
 LocalDate get openedOn;/// 本番の日。
 LocalDate? get deadline; String? get deadlineName; String? get deadlinePresetId;/// 毎日の一歩。
 String? get dailyAction; DarumaStatus get status; DateTime? get completedAt; DateTime? get retiredAt; int get sizeRank;/// 「ひと回り大きいだるま」のやり直し元。
 String? get parentId;/// 眉とひげの揺らぎの種。
 int get seed;/// 期限日に1回だけ「叶った？」と聞いたか。
 bool get askedAtDeadline;
/// Create a copy of Daruma
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DarumaCopyWith<Daruma> get copyWith => _$DarumaCopyWithImpl<Daruma>(this as Daruma, _$identity);

  /// Serializes this Daruma to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Daruma;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Daruma&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.colorId, _this.colorId) || other.colorId == _this.colorId)&&(identical(other.eyeSide, _this.eyeSide) || other.eyeSide == _this.eyeSide)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.openedOn, _this.openedOn) || other.openedOn == _this.openedOn)&&(identical(other.deadline, _this.deadline) || other.deadline == _this.deadline)&&(identical(other.deadlineName, _this.deadlineName) || other.deadlineName == _this.deadlineName)&&(identical(other.deadlinePresetId, _this.deadlinePresetId) || other.deadlinePresetId == _this.deadlinePresetId)&&(identical(other.dailyAction, _this.dailyAction) || other.dailyAction == _this.dailyAction)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.completedAt, _this.completedAt) || other.completedAt == _this.completedAt)&&(identical(other.retiredAt, _this.retiredAt) || other.retiredAt == _this.retiredAt)&&(identical(other.sizeRank, _this.sizeRank) || other.sizeRank == _this.sizeRank)&&(identical(other.parentId, _this.parentId) || other.parentId == _this.parentId)&&(identical(other.seed, _this.seed) || other.seed == _this.seed)&&(identical(other.askedAtDeadline, _this.askedAtDeadline) || other.askedAtDeadline == _this.askedAtDeadline));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Daruma;
  return Object.hash(runtimeType,_this.id,_this.name,_this.colorId,_this.eyeSide,_this.createdAt,_this.openedOn,_this.deadline,_this.deadlineName,_this.deadlinePresetId,_this.dailyAction,_this.status,_this.completedAt,_this.retiredAt,_this.sizeRank,_this.parentId,_this.seed,_this.askedAtDeadline);
}

@override
String toString() {
  final _this = this as Daruma;
  return 'Daruma(id: ${_this.id}, name: ${_this.name}, colorId: ${_this.colorId}, eyeSide: ${_this.eyeSide}, createdAt: ${_this.createdAt}, openedOn: ${_this.openedOn}, deadline: ${_this.deadline}, deadlineName: ${_this.deadlineName}, deadlinePresetId: ${_this.deadlinePresetId}, dailyAction: ${_this.dailyAction}, status: ${_this.status}, completedAt: ${_this.completedAt}, retiredAt: ${_this.retiredAt}, sizeRank: ${_this.sizeRank}, parentId: ${_this.parentId}, seed: ${_this.seed}, askedAtDeadline: ${_this.askedAtDeadline})';
}


}

/// @nodoc
abstract mixin class $DarumaCopyWith<$Res>  {
  factory $DarumaCopyWith(Daruma value, $Res Function(Daruma) _then) = _$DarumaCopyWithImpl;
@useResult
$Res call({
 String id, String name, int colorId, EyeSide eyeSide, DateTime createdAt, LocalDate openedOn, LocalDate? deadline, String? deadlineName, String? deadlinePresetId, String? dailyAction, DarumaStatus status, DateTime? completedAt, DateTime? retiredAt, int sizeRank, String? parentId, int seed, bool askedAtDeadline
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? colorId = null,Object? eyeSide = null,Object? createdAt = null,Object? openedOn = null,Object? deadline = freezed,Object? deadlineName = freezed,Object? deadlinePresetId = freezed,Object? dailyAction = freezed,Object? status = null,Object? completedAt = freezed,Object? retiredAt = freezed,Object? sizeRank = null,Object? parentId = freezed,Object? seed = null,Object? askedAtDeadline = null,}) {
  return _then(Daruma(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,colorId: null == colorId ? _self.colorId : colorId // ignore: cast_nullable_to_non_nullable
as int,eyeSide: null == eyeSide ? _self.eyeSide : eyeSide // ignore: cast_nullable_to_non_nullable
as EyeSide,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,openedOn: null == openedOn ? _self.openedOn : openedOn // ignore: cast_nullable_to_non_nullable
as LocalDate,deadline: freezed == deadline ? _self.deadline : deadline // ignore: cast_nullable_to_non_nullable
as LocalDate?,deadlineName: freezed == deadlineName ? _self.deadlineName : deadlineName // ignore: cast_nullable_to_non_nullable
as String?,deadlinePresetId: freezed == deadlinePresetId ? _self.deadlinePresetId : deadlinePresetId // ignore: cast_nullable_to_non_nullable
as String?,dailyAction: freezed == dailyAction ? _self.dailyAction : dailyAction // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DarumaStatus,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,retiredAt: freezed == retiredAt ? _self.retiredAt : retiredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,sizeRank: null == sizeRank ? _self.sizeRank : sizeRank // ignore: cast_nullable_to_non_nullable
as int,parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as String?,seed: null == seed ? _self.seed : seed // ignore: cast_nullable_to_non_nullable
as int,askedAtDeadline: null == askedAtDeadline ? _self.askedAtDeadline : askedAtDeadline // ignore: cast_nullable_to_non_nullable
as bool,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  int colorId,  EyeSide eyeSide,  DateTime createdAt,  LocalDate openedOn,  LocalDate? deadline,  String? deadlineName,  String? deadlinePresetId,  String? dailyAction,  DarumaStatus status,  DateTime? completedAt,  DateTime? retiredAt,  int sizeRank,  String? parentId,  int seed,  bool askedAtDeadline)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Daruma() when $default != null:
return $default(_that.id,_that.name,_that.colorId,_that.eyeSide,_that.createdAt,_that.openedOn,_that.deadline,_that.deadlineName,_that.deadlinePresetId,_that.dailyAction,_that.status,_that.completedAt,_that.retiredAt,_that.sizeRank,_that.parentId,_that.seed,_that.askedAtDeadline);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  int colorId,  EyeSide eyeSide,  DateTime createdAt,  LocalDate openedOn,  LocalDate? deadline,  String? deadlineName,  String? deadlinePresetId,  String? dailyAction,  DarumaStatus status,  DateTime? completedAt,  DateTime? retiredAt,  int sizeRank,  String? parentId,  int seed,  bool askedAtDeadline)  $default,) {final _that = this;
switch (_that) {
case _Daruma():
return $default(_that.id,_that.name,_that.colorId,_that.eyeSide,_that.createdAt,_that.openedOn,_that.deadline,_that.deadlineName,_that.deadlinePresetId,_that.dailyAction,_that.status,_that.completedAt,_that.retiredAt,_that.sizeRank,_that.parentId,_that.seed,_that.askedAtDeadline);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  int colorId,  EyeSide eyeSide,  DateTime createdAt,  LocalDate openedOn,  LocalDate? deadline,  String? deadlineName,  String? deadlinePresetId,  String? dailyAction,  DarumaStatus status,  DateTime? completedAt,  DateTime? retiredAt,  int sizeRank,  String? parentId,  int seed,  bool askedAtDeadline)?  $default,) {final _that = this;
switch (_that) {
case _Daruma() when $default != null:
return $default(_that.id,_that.name,_that.colorId,_that.eyeSide,_that.createdAt,_that.openedOn,_that.deadline,_that.deadlineName,_that.deadlinePresetId,_that.dailyAction,_that.status,_that.completedAt,_that.retiredAt,_that.sizeRank,_that.parentId,_that.seed,_that.askedAtDeadline);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Daruma extends Daruma {
  const _Daruma({required this.id, required this.name, required this.colorId, required this.eyeSide, required this.createdAt, required this.openedOn, this.deadline, this.deadlineName, this.deadlinePresetId, this.dailyAction, required this.status, this.completedAt, this.retiredAt, this.sizeRank = 1, this.parentId, required this.seed, this.askedAtDeadline = false}): super._();
  factory _Daruma.fromJson(Map<String, dynamic> json) => _$DarumaFromJson(json);

@override final  String id;
/// 腹の文字（2〜6字）。
@override final  String name;
@override final  int colorId;
@override final  EyeSide eyeSide;
@override final  DateTime createdAt;
/// 開眼日（端末のローカル日付）。
@override final  LocalDate openedOn;
/// 本番の日。
@override final  LocalDate? deadline;
@override final  String? deadlineName;
@override final  String? deadlinePresetId;
/// 毎日の一歩。
@override final  String? dailyAction;
@override final  DarumaStatus status;
@override final  DateTime? completedAt;
@override final  DateTime? retiredAt;
@override@JsonKey() final  int sizeRank;
/// 「ひと回り大きいだるま」のやり直し元。
@override final  String? parentId;
/// 眉とひげの揺らぎの種。
@override final  int seed;
/// 期限日に1回だけ「叶った？」と聞いたか。
@override@JsonKey() final  bool askedAtDeadline;

/// Create a copy of Daruma
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DarumaCopyWith<_Daruma> get copyWith => __$DarumaCopyWithImpl<_Daruma>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DarumaToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Daruma&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.colorId, colorId) || other.colorId == colorId)&&(identical(other.eyeSide, eyeSide) || other.eyeSide == eyeSide)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.openedOn, openedOn) || other.openedOn == openedOn)&&(identical(other.deadline, deadline) || other.deadline == deadline)&&(identical(other.deadlineName, deadlineName) || other.deadlineName == deadlineName)&&(identical(other.deadlinePresetId, deadlinePresetId) || other.deadlinePresetId == deadlinePresetId)&&(identical(other.dailyAction, dailyAction) || other.dailyAction == dailyAction)&&(identical(other.status, status) || other.status == status)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.retiredAt, retiredAt) || other.retiredAt == retiredAt)&&(identical(other.sizeRank, sizeRank) || other.sizeRank == sizeRank)&&(identical(other.parentId, parentId) || other.parentId == parentId)&&(identical(other.seed, seed) || other.seed == seed)&&(identical(other.askedAtDeadline, askedAtDeadline) || other.askedAtDeadline == askedAtDeadline));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,colorId,eyeSide,createdAt,openedOn,deadline,deadlineName,deadlinePresetId,dailyAction,status,completedAt,retiredAt,sizeRank,parentId,seed,askedAtDeadline);
}

@override
String toString() {
    return 'Daruma(id: $id, name: $name, colorId: $colorId, eyeSide: $eyeSide, createdAt: $createdAt, openedOn: $openedOn, deadline: $deadline, deadlineName: $deadlineName, deadlinePresetId: $deadlinePresetId, dailyAction: $dailyAction, status: $status, completedAt: $completedAt, retiredAt: $retiredAt, sizeRank: $sizeRank, parentId: $parentId, seed: $seed, askedAtDeadline: $askedAtDeadline)';
}


}

/// @nodoc
abstract mixin class _$DarumaCopyWith<$Res> implements $DarumaCopyWith<$Res> {
  factory _$DarumaCopyWith(_Daruma value, $Res Function(_Daruma) _then) = __$DarumaCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, int colorId, EyeSide eyeSide, DateTime createdAt, LocalDate openedOn, LocalDate? deadline, String? deadlineName, String? deadlinePresetId, String? dailyAction, DarumaStatus status, DateTime? completedAt, DateTime? retiredAt, int sizeRank, String? parentId, int seed, bool askedAtDeadline
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? colorId = null,Object? eyeSide = null,Object? createdAt = null,Object? openedOn = null,Object? deadline = freezed,Object? deadlineName = freezed,Object? deadlinePresetId = freezed,Object? dailyAction = freezed,Object? status = null,Object? completedAt = freezed,Object? retiredAt = freezed,Object? sizeRank = null,Object? parentId = freezed,Object? seed = null,Object? askedAtDeadline = null,}) {
  return _then(_Daruma(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,colorId: null == colorId ? _self.colorId : colorId // ignore: cast_nullable_to_non_nullable
as int,eyeSide: null == eyeSide ? _self.eyeSide : eyeSide // ignore: cast_nullable_to_non_nullable
as EyeSide,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,openedOn: null == openedOn ? _self.openedOn : openedOn // ignore: cast_nullable_to_non_nullable
as LocalDate,deadline: freezed == deadline ? _self.deadline : deadline // ignore: cast_nullable_to_non_nullable
as LocalDate?,deadlineName: freezed == deadlineName ? _self.deadlineName : deadlineName // ignore: cast_nullable_to_non_nullable
as String?,deadlinePresetId: freezed == deadlinePresetId ? _self.deadlinePresetId : deadlinePresetId // ignore: cast_nullable_to_non_nullable
as String?,dailyAction: freezed == dailyAction ? _self.dailyAction : dailyAction // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DarumaStatus,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,retiredAt: freezed == retiredAt ? _self.retiredAt : retiredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,sizeRank: null == sizeRank ? _self.sizeRank : sizeRank // ignore: cast_nullable_to_non_nullable
as int,parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as String?,seed: null == seed ? _self.seed : seed // ignore: cast_nullable_to_non_nullable
as int,askedAtDeadline: null == askedAtDeadline ? _self.askedAtDeadline : askedAtDeadline // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$Milestone {

 String get id; String get darumaId; String get name; LocalDate get date; String? get presetId;
/// Create a copy of Milestone
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MilestoneCopyWith<Milestone> get copyWith => _$MilestoneCopyWithImpl<Milestone>(this as Milestone, _$identity);

  /// Serializes this Milestone to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Milestone;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Milestone&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.darumaId, _this.darumaId) || other.darumaId == _this.darumaId)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.date, _this.date) || other.date == _this.date)&&(identical(other.presetId, _this.presetId) || other.presetId == _this.presetId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Milestone;
  return Object.hash(runtimeType,_this.id,_this.darumaId,_this.name,_this.date,_this.presetId);
}

@override
String toString() {
  final _this = this as Milestone;
  return 'Milestone(id: ${_this.id}, darumaId: ${_this.darumaId}, name: ${_this.name}, date: ${_this.date}, presetId: ${_this.presetId})';
}


}

/// @nodoc
abstract mixin class $MilestoneCopyWith<$Res>  {
  factory $MilestoneCopyWith(Milestone value, $Res Function(Milestone) _then) = _$MilestoneCopyWithImpl;
@useResult
$Res call({
 String id, String darumaId, String name, LocalDate date, String? presetId
});




}
/// @nodoc
class _$MilestoneCopyWithImpl<$Res>
    implements $MilestoneCopyWith<$Res> {
  _$MilestoneCopyWithImpl(this._self, this._then);

  final Milestone _self;
  final $Res Function(Milestone) _then;

/// Create a copy of Milestone
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? darumaId = null,Object? name = null,Object? date = null,Object? presetId = freezed,}) {
  return _then(Milestone(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,darumaId: null == darumaId ? _self.darumaId : darumaId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as LocalDate,presetId: freezed == presetId ? _self.presetId : presetId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Milestone].
extension MilestonePatterns on Milestone {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Milestone value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Milestone() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Milestone value)  $default,){
final _that = this;
switch (_that) {
case _Milestone():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Milestone value)?  $default,){
final _that = this;
switch (_that) {
case _Milestone() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String darumaId,  String name,  LocalDate date,  String? presetId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Milestone() when $default != null:
return $default(_that.id,_that.darumaId,_that.name,_that.date,_that.presetId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String darumaId,  String name,  LocalDate date,  String? presetId)  $default,) {final _that = this;
switch (_that) {
case _Milestone():
return $default(_that.id,_that.darumaId,_that.name,_that.date,_that.presetId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String darumaId,  String name,  LocalDate date,  String? presetId)?  $default,) {final _that = this;
switch (_that) {
case _Milestone() when $default != null:
return $default(_that.id,_that.darumaId,_that.name,_that.date,_that.presetId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Milestone extends Milestone {
  const _Milestone({required this.id, required this.darumaId, required this.name, required this.date, this.presetId}): super._();
  factory _Milestone.fromJson(Map<String, dynamic> json) => _$MilestoneFromJson(json);

@override final  String id;
@override final  String darumaId;
@override final  String name;
@override final  LocalDate date;
@override final  String? presetId;

/// Create a copy of Milestone
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MilestoneCopyWith<_Milestone> get copyWith => __$MilestoneCopyWithImpl<_Milestone>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MilestoneToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Milestone&&(identical(other.id, id) || other.id == id)&&(identical(other.darumaId, darumaId) || other.darumaId == darumaId)&&(identical(other.name, name) || other.name == name)&&(identical(other.date, date) || other.date == date)&&(identical(other.presetId, presetId) || other.presetId == presetId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,darumaId,name,date,presetId);
}

@override
String toString() {
    return 'Milestone(id: $id, darumaId: $darumaId, name: $name, date: $date, presetId: $presetId)';
}


}

/// @nodoc
abstract mixin class _$MilestoneCopyWith<$Res> implements $MilestoneCopyWith<$Res> {
  factory _$MilestoneCopyWith(_Milestone value, $Res Function(_Milestone) _then) = __$MilestoneCopyWithImpl;
@override @useResult
$Res call({
 String id, String darumaId, String name, LocalDate date, String? presetId
});




}
/// @nodoc
class __$MilestoneCopyWithImpl<$Res>
    implements _$MilestoneCopyWith<$Res> {
  __$MilestoneCopyWithImpl(this._self, this._then);

  final _Milestone _self;
  final $Res Function(_Milestone) _then;

/// Create a copy of Milestone
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? darumaId = null,Object? name = null,Object? date = null,Object? presetId = freezed,}) {
  return _then(_Milestone(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,darumaId: null == darumaId ? _self.darumaId : darumaId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as LocalDate,presetId: freezed == presetId ? _self.presetId : presetId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$Checkin {

 String get id; String get darumaId;/// 端末のローカル日付。darumaId と合わせて一意。
 LocalDate get date; CheckinKind get kind;/// 30字のメモ（任意）。
 String? get memo; DateTime get createdAt;
/// Create a copy of Checkin
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CheckinCopyWith<Checkin> get copyWith => _$CheckinCopyWithImpl<Checkin>(this as Checkin, _$identity);

  /// Serializes this Checkin to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Checkin;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Checkin&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.darumaId, _this.darumaId) || other.darumaId == _this.darumaId)&&(identical(other.date, _this.date) || other.date == _this.date)&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.memo, _this.memo) || other.memo == _this.memo)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Checkin;
  return Object.hash(runtimeType,_this.id,_this.darumaId,_this.date,_this.kind,_this.memo,_this.createdAt);
}

@override
String toString() {
  final _this = this as Checkin;
  return 'Checkin(id: ${_this.id}, darumaId: ${_this.darumaId}, date: ${_this.date}, kind: ${_this.kind}, memo: ${_this.memo}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $CheckinCopyWith<$Res>  {
  factory $CheckinCopyWith(Checkin value, $Res Function(Checkin) _then) = _$CheckinCopyWithImpl;
@useResult
$Res call({
 String id, String darumaId, LocalDate date, CheckinKind kind, String? memo, DateTime createdAt
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? darumaId = null,Object? date = null,Object? kind = null,Object? memo = freezed,Object? createdAt = null,}) {
  return _then(Checkin(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,darumaId: null == darumaId ? _self.darumaId : darumaId // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as LocalDate,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as CheckinKind,memo: freezed == memo ? _self.memo : memo // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String darumaId,  LocalDate date,  CheckinKind kind,  String? memo,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Checkin() when $default != null:
return $default(_that.id,_that.darumaId,_that.date,_that.kind,_that.memo,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String darumaId,  LocalDate date,  CheckinKind kind,  String? memo,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _Checkin():
return $default(_that.id,_that.darumaId,_that.date,_that.kind,_that.memo,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String darumaId,  LocalDate date,  CheckinKind kind,  String? memo,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Checkin() when $default != null:
return $default(_that.id,_that.darumaId,_that.date,_that.kind,_that.memo,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Checkin implements Checkin {
  const _Checkin({required this.id, required this.darumaId, required this.date, required this.kind, this.memo, required this.createdAt});
  factory _Checkin.fromJson(Map<String, dynamic> json) => _$CheckinFromJson(json);

@override final  String id;
@override final  String darumaId;
/// 端末のローカル日付。darumaId と合わせて一意。
@override final  LocalDate date;
@override final  CheckinKind kind;
/// 30字のメモ（任意）。
@override final  String? memo;
@override final  DateTime createdAt;

/// Create a copy of Checkin
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CheckinCopyWith<_Checkin> get copyWith => __$CheckinCopyWithImpl<_Checkin>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CheckinToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Checkin&&(identical(other.id, id) || other.id == id)&&(identical(other.darumaId, darumaId) || other.darumaId == darumaId)&&(identical(other.date, date) || other.date == date)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.memo, memo) || other.memo == memo)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,darumaId,date,kind,memo,createdAt);
}

@override
String toString() {
    return 'Checkin(id: $id, darumaId: $darumaId, date: $date, kind: $kind, memo: $memo, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$CheckinCopyWith<$Res> implements $CheckinCopyWith<$Res> {
  factory _$CheckinCopyWith(_Checkin value, $Res Function(_Checkin) _then) = __$CheckinCopyWithImpl;
@override @useResult
$Res call({
 String id, String darumaId, LocalDate date, CheckinKind kind, String? memo, DateTime createdAt
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? darumaId = null,Object? date = null,Object? kind = null,Object? memo = freezed,Object? createdAt = null,}) {
  return _then(_Checkin(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,darumaId: null == darumaId ? _self.darumaId : darumaId // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as LocalDate,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as CheckinKind,memo: freezed == memo ? _self.memo : memo // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$Recovery {

 String get id; String get darumaId;/// 転ぶ前に最後に記録した日。
 LocalDate get fellAfter;/// 起き上がった日。
 LocalDate get roseOn;
/// Create a copy of Recovery
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecoveryCopyWith<Recovery> get copyWith => _$RecoveryCopyWithImpl<Recovery>(this as Recovery, _$identity);

  /// Serializes this Recovery to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Recovery;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Recovery&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.darumaId, _this.darumaId) || other.darumaId == _this.darumaId)&&(identical(other.fellAfter, _this.fellAfter) || other.fellAfter == _this.fellAfter)&&(identical(other.roseOn, _this.roseOn) || other.roseOn == _this.roseOn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
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
 String id, String darumaId, LocalDate fellAfter, LocalDate roseOn
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
as String,darumaId: null == darumaId ? _self.darumaId : darumaId // ignore: cast_nullable_to_non_nullable
as String,fellAfter: null == fellAfter ? _self.fellAfter : fellAfter // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String darumaId,  LocalDate fellAfter,  LocalDate roseOn)?  $default,{required TResult orElse(),}) {final _that = this;
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String darumaId,  LocalDate fellAfter,  LocalDate roseOn)  $default,) {final _that = this;
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String darumaId,  LocalDate fellAfter,  LocalDate roseOn)?  $default,) {final _that = this;
switch (_that) {
case _Recovery() when $default != null:
return $default(_that.id,_that.darumaId,_that.fellAfter,_that.roseOn);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Recovery implements Recovery {
  const _Recovery({required this.id, required this.darumaId, required this.fellAfter, required this.roseOn});
  factory _Recovery.fromJson(Map<String, dynamic> json) => _$RecoveryFromJson(json);

@override final  String id;
@override final  String darumaId;
/// 転ぶ前に最後に記録した日。
@override final  LocalDate fellAfter;
/// 起き上がった日。
@override final  LocalDate roseOn;

/// Create a copy of Recovery
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecoveryCopyWith<_Recovery> get copyWith => __$RecoveryCopyWithImpl<_Recovery>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RecoveryToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Recovery&&(identical(other.id, id) || other.id == id)&&(identical(other.darumaId, darumaId) || other.darumaId == darumaId)&&(identical(other.fellAfter, fellAfter) || other.fellAfter == fellAfter)&&(identical(other.roseOn, roseOn) || other.roseOn == roseOn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
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
 String id, String darumaId, LocalDate fellAfter, LocalDate roseOn
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
as String,darumaId: null == darumaId ? _self.darumaId : darumaId // ignore: cast_nullable_to_non_nullable
as String,fellAfter: null == fellAfter ? _self.fellAfter : fellAfter // ignore: cast_nullable_to_non_nullable
as LocalDate,roseOn: null == roseOn ? _self.roseOn : roseOn // ignore: cast_nullable_to_non_nullable
as LocalDate,
  ));
}


}


/// @nodoc
mixin _$DarumaLook {

 String get darumaId; String get text; int get colorId; int get seed;/// 筆の数（step の件数）。
 int get strokes;/// 台座の金の筋＝起き上がり回数。
 int get goldLines; EyeSide get firstEye; EyeState get eyes; int get sizeRank; bool get fallen; DarumaStatus get status; LocalDate? get openedOn; LocalDate? get completedOn; int? get daysLeft; String? get deadlineName; int get streak; bool get recordedToday; int get daysSinceOpened;
/// Create a copy of DarumaLook
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DarumaLookCopyWith<DarumaLook> get copyWith => _$DarumaLookCopyWithImpl<DarumaLook>(this as DarumaLook, _$identity);

  /// Serializes this DarumaLook to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DarumaLook;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DarumaLook&&(identical(other.darumaId, _this.darumaId) || other.darumaId == _this.darumaId)&&(identical(other.text, _this.text) || other.text == _this.text)&&(identical(other.colorId, _this.colorId) || other.colorId == _this.colorId)&&(identical(other.seed, _this.seed) || other.seed == _this.seed)&&(identical(other.strokes, _this.strokes) || other.strokes == _this.strokes)&&(identical(other.goldLines, _this.goldLines) || other.goldLines == _this.goldLines)&&(identical(other.firstEye, _this.firstEye) || other.firstEye == _this.firstEye)&&(identical(other.eyes, _this.eyes) || other.eyes == _this.eyes)&&(identical(other.sizeRank, _this.sizeRank) || other.sizeRank == _this.sizeRank)&&(identical(other.fallen, _this.fallen) || other.fallen == _this.fallen)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.openedOn, _this.openedOn) || other.openedOn == _this.openedOn)&&(identical(other.completedOn, _this.completedOn) || other.completedOn == _this.completedOn)&&(identical(other.daysLeft, _this.daysLeft) || other.daysLeft == _this.daysLeft)&&(identical(other.deadlineName, _this.deadlineName) || other.deadlineName == _this.deadlineName)&&(identical(other.streak, _this.streak) || other.streak == _this.streak)&&(identical(other.recordedToday, _this.recordedToday) || other.recordedToday == _this.recordedToday)&&(identical(other.daysSinceOpened, _this.daysSinceOpened) || other.daysSinceOpened == _this.daysSinceOpened));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DarumaLook;
  return Object.hash(runtimeType,_this.darumaId,_this.text,_this.colorId,_this.seed,_this.strokes,_this.goldLines,_this.firstEye,_this.eyes,_this.sizeRank,_this.fallen,_this.status,_this.openedOn,_this.completedOn,_this.daysLeft,_this.deadlineName,_this.streak,_this.recordedToday,_this.daysSinceOpened);
}

@override
String toString() {
  final _this = this as DarumaLook;
  return 'DarumaLook(darumaId: ${_this.darumaId}, text: ${_this.text}, colorId: ${_this.colorId}, seed: ${_this.seed}, strokes: ${_this.strokes}, goldLines: ${_this.goldLines}, firstEye: ${_this.firstEye}, eyes: ${_this.eyes}, sizeRank: ${_this.sizeRank}, fallen: ${_this.fallen}, status: ${_this.status}, openedOn: ${_this.openedOn}, completedOn: ${_this.completedOn}, daysLeft: ${_this.daysLeft}, deadlineName: ${_this.deadlineName}, streak: ${_this.streak}, recordedToday: ${_this.recordedToday}, daysSinceOpened: ${_this.daysSinceOpened})';
}


}

/// @nodoc
abstract mixin class $DarumaLookCopyWith<$Res>  {
  factory $DarumaLookCopyWith(DarumaLook value, $Res Function(DarumaLook) _then) = _$DarumaLookCopyWithImpl;
@useResult
$Res call({
 String darumaId, String text, int colorId, int seed, int strokes, int goldLines, EyeSide firstEye, EyeState eyes, int sizeRank, bool fallen, DarumaStatus status, LocalDate? openedOn, LocalDate? completedOn, int? daysLeft, String? deadlineName, int streak, bool recordedToday, int daysSinceOpened
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
@pragma('vm:prefer-inline') @override $Res call({Object? darumaId = null,Object? text = null,Object? colorId = null,Object? seed = null,Object? strokes = null,Object? goldLines = null,Object? firstEye = null,Object? eyes = null,Object? sizeRank = null,Object? fallen = null,Object? status = null,Object? openedOn = freezed,Object? completedOn = freezed,Object? daysLeft = freezed,Object? deadlineName = freezed,Object? streak = null,Object? recordedToday = null,Object? daysSinceOpened = null,}) {
  return _then(DarumaLook(
darumaId: null == darumaId ? _self.darumaId : darumaId // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,colorId: null == colorId ? _self.colorId : colorId // ignore: cast_nullable_to_non_nullable
as int,seed: null == seed ? _self.seed : seed // ignore: cast_nullable_to_non_nullable
as int,strokes: null == strokes ? _self.strokes : strokes // ignore: cast_nullable_to_non_nullable
as int,goldLines: null == goldLines ? _self.goldLines : goldLines // ignore: cast_nullable_to_non_nullable
as int,firstEye: null == firstEye ? _self.firstEye : firstEye // ignore: cast_nullable_to_non_nullable
as EyeSide,eyes: null == eyes ? _self.eyes : eyes // ignore: cast_nullable_to_non_nullable
as EyeState,sizeRank: null == sizeRank ? _self.sizeRank : sizeRank // ignore: cast_nullable_to_non_nullable
as int,fallen: null == fallen ? _self.fallen : fallen // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DarumaStatus,openedOn: freezed == openedOn ? _self.openedOn : openedOn // ignore: cast_nullable_to_non_nullable
as LocalDate?,completedOn: freezed == completedOn ? _self.completedOn : completedOn // ignore: cast_nullable_to_non_nullable
as LocalDate?,daysLeft: freezed == daysLeft ? _self.daysLeft : daysLeft // ignore: cast_nullable_to_non_nullable
as int?,deadlineName: freezed == deadlineName ? _self.deadlineName : deadlineName // ignore: cast_nullable_to_non_nullable
as String?,streak: null == streak ? _self.streak : streak // ignore: cast_nullable_to_non_nullable
as int,recordedToday: null == recordedToday ? _self.recordedToday : recordedToday // ignore: cast_nullable_to_non_nullable
as bool,daysSinceOpened: null == daysSinceOpened ? _self.daysSinceOpened : daysSinceOpened // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String darumaId,  String text,  int colorId,  int seed,  int strokes,  int goldLines,  EyeSide firstEye,  EyeState eyes,  int sizeRank,  bool fallen,  DarumaStatus status,  LocalDate? openedOn,  LocalDate? completedOn,  int? daysLeft,  String? deadlineName,  int streak,  bool recordedToday,  int daysSinceOpened)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DarumaLook() when $default != null:
return $default(_that.darumaId,_that.text,_that.colorId,_that.seed,_that.strokes,_that.goldLines,_that.firstEye,_that.eyes,_that.sizeRank,_that.fallen,_that.status,_that.openedOn,_that.completedOn,_that.daysLeft,_that.deadlineName,_that.streak,_that.recordedToday,_that.daysSinceOpened);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String darumaId,  String text,  int colorId,  int seed,  int strokes,  int goldLines,  EyeSide firstEye,  EyeState eyes,  int sizeRank,  bool fallen,  DarumaStatus status,  LocalDate? openedOn,  LocalDate? completedOn,  int? daysLeft,  String? deadlineName,  int streak,  bool recordedToday,  int daysSinceOpened)  $default,) {final _that = this;
switch (_that) {
case _DarumaLook():
return $default(_that.darumaId,_that.text,_that.colorId,_that.seed,_that.strokes,_that.goldLines,_that.firstEye,_that.eyes,_that.sizeRank,_that.fallen,_that.status,_that.openedOn,_that.completedOn,_that.daysLeft,_that.deadlineName,_that.streak,_that.recordedToday,_that.daysSinceOpened);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String darumaId,  String text,  int colorId,  int seed,  int strokes,  int goldLines,  EyeSide firstEye,  EyeState eyes,  int sizeRank,  bool fallen,  DarumaStatus status,  LocalDate? openedOn,  LocalDate? completedOn,  int? daysLeft,  String? deadlineName,  int streak,  bool recordedToday,  int daysSinceOpened)?  $default,) {final _that = this;
switch (_that) {
case _DarumaLook() when $default != null:
return $default(_that.darumaId,_that.text,_that.colorId,_that.seed,_that.strokes,_that.goldLines,_that.firstEye,_that.eyes,_that.sizeRank,_that.fallen,_that.status,_that.openedOn,_that.completedOn,_that.daysLeft,_that.deadlineName,_that.streak,_that.recordedToday,_that.daysSinceOpened);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DarumaLook extends DarumaLook {
  const _DarumaLook({required this.darumaId, required this.text, required this.colorId, required this.seed, required this.strokes, required this.goldLines, required this.firstEye, required this.eyes, required this.sizeRank, required this.fallen, required this.status, this.openedOn, this.completedOn, this.daysLeft, this.deadlineName, this.streak = 0, this.recordedToday = false, this.daysSinceOpened = 0}): super._();
  factory _DarumaLook.fromJson(Map<String, dynamic> json) => _$DarumaLookFromJson(json);

@override final  String darumaId;
@override final  String text;
@override final  int colorId;
@override final  int seed;
/// 筆の数（step の件数）。
@override final  int strokes;
/// 台座の金の筋＝起き上がり回数。
@override final  int goldLines;
@override final  EyeSide firstEye;
@override final  EyeState eyes;
@override final  int sizeRank;
@override final  bool fallen;
@override final  DarumaStatus status;
@override final  LocalDate? openedOn;
@override final  LocalDate? completedOn;
@override final  int? daysLeft;
@override final  String? deadlineName;
@override@JsonKey() final  int streak;
@override@JsonKey() final  bool recordedToday;
@override@JsonKey() final  int daysSinceOpened;

/// Create a copy of DarumaLook
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DarumaLookCopyWith<_DarumaLook> get copyWith => __$DarumaLookCopyWithImpl<_DarumaLook>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DarumaLookToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DarumaLook&&(identical(other.darumaId, darumaId) || other.darumaId == darumaId)&&(identical(other.text, text) || other.text == text)&&(identical(other.colorId, colorId) || other.colorId == colorId)&&(identical(other.seed, seed) || other.seed == seed)&&(identical(other.strokes, strokes) || other.strokes == strokes)&&(identical(other.goldLines, goldLines) || other.goldLines == goldLines)&&(identical(other.firstEye, firstEye) || other.firstEye == firstEye)&&(identical(other.eyes, eyes) || other.eyes == eyes)&&(identical(other.sizeRank, sizeRank) || other.sizeRank == sizeRank)&&(identical(other.fallen, fallen) || other.fallen == fallen)&&(identical(other.status, status) || other.status == status)&&(identical(other.openedOn, openedOn) || other.openedOn == openedOn)&&(identical(other.completedOn, completedOn) || other.completedOn == completedOn)&&(identical(other.daysLeft, daysLeft) || other.daysLeft == daysLeft)&&(identical(other.deadlineName, deadlineName) || other.deadlineName == deadlineName)&&(identical(other.streak, streak) || other.streak == streak)&&(identical(other.recordedToday, recordedToday) || other.recordedToday == recordedToday)&&(identical(other.daysSinceOpened, daysSinceOpened) || other.daysSinceOpened == daysSinceOpened));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,darumaId,text,colorId,seed,strokes,goldLines,firstEye,eyes,sizeRank,fallen,status,openedOn,completedOn,daysLeft,deadlineName,streak,recordedToday,daysSinceOpened);
}

@override
String toString() {
    return 'DarumaLook(darumaId: $darumaId, text: $text, colorId: $colorId, seed: $seed, strokes: $strokes, goldLines: $goldLines, firstEye: $firstEye, eyes: $eyes, sizeRank: $sizeRank, fallen: $fallen, status: $status, openedOn: $openedOn, completedOn: $completedOn, daysLeft: $daysLeft, deadlineName: $deadlineName, streak: $streak, recordedToday: $recordedToday, daysSinceOpened: $daysSinceOpened)';
}


}

/// @nodoc
abstract mixin class _$DarumaLookCopyWith<$Res> implements $DarumaLookCopyWith<$Res> {
  factory _$DarumaLookCopyWith(_DarumaLook value, $Res Function(_DarumaLook) _then) = __$DarumaLookCopyWithImpl;
@override @useResult
$Res call({
 String darumaId, String text, int colorId, int seed, int strokes, int goldLines, EyeSide firstEye, EyeState eyes, int sizeRank, bool fallen, DarumaStatus status, LocalDate? openedOn, LocalDate? completedOn, int? daysLeft, String? deadlineName, int streak, bool recordedToday, int daysSinceOpened
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
@override @pragma('vm:prefer-inline') $Res call({Object? darumaId = null,Object? text = null,Object? colorId = null,Object? seed = null,Object? strokes = null,Object? goldLines = null,Object? firstEye = null,Object? eyes = null,Object? sizeRank = null,Object? fallen = null,Object? status = null,Object? openedOn = freezed,Object? completedOn = freezed,Object? daysLeft = freezed,Object? deadlineName = freezed,Object? streak = null,Object? recordedToday = null,Object? daysSinceOpened = null,}) {
  return _then(_DarumaLook(
darumaId: null == darumaId ? _self.darumaId : darumaId // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,colorId: null == colorId ? _self.colorId : colorId // ignore: cast_nullable_to_non_nullable
as int,seed: null == seed ? _self.seed : seed // ignore: cast_nullable_to_non_nullable
as int,strokes: null == strokes ? _self.strokes : strokes // ignore: cast_nullable_to_non_nullable
as int,goldLines: null == goldLines ? _self.goldLines : goldLines // ignore: cast_nullable_to_non_nullable
as int,firstEye: null == firstEye ? _self.firstEye : firstEye // ignore: cast_nullable_to_non_nullable
as EyeSide,eyes: null == eyes ? _self.eyes : eyes // ignore: cast_nullable_to_non_nullable
as EyeState,sizeRank: null == sizeRank ? _self.sizeRank : sizeRank // ignore: cast_nullable_to_non_nullable
as int,fallen: null == fallen ? _self.fallen : fallen // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DarumaStatus,openedOn: freezed == openedOn ? _self.openedOn : openedOn // ignore: cast_nullable_to_non_nullable
as LocalDate?,completedOn: freezed == completedOn ? _self.completedOn : completedOn // ignore: cast_nullable_to_non_nullable
as LocalDate?,daysLeft: freezed == daysLeft ? _self.daysLeft : daysLeft // ignore: cast_nullable_to_non_nullable
as int?,deadlineName: freezed == deadlineName ? _self.deadlineName : deadlineName // ignore: cast_nullable_to_non_nullable
as String?,streak: null == streak ? _self.streak : streak // ignore: cast_nullable_to_non_nullable
as int,recordedToday: null == recordedToday ? _self.recordedToday : recordedToday // ignore: cast_nullable_to_non_nullable
as bool,daysSinceOpened: null == daysSinceOpened ? _self.daysSinceOpened : daysSinceOpened // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$AppSettings {

/// リマインド通知。既定オフ。
 bool get reminderEnabled;/// 通知時刻（0時からの分）。既定 20:00。
 int get reminderMinuteOfDay; EyeSide get eyeSideDefault; WidgetStyle get widgetStyle; bool get onboardingDone;/// 評価依頼を出した日。365日3回まで。
 List<LocalDate> get reviewPromptedOn;/// ウィジェットに出すだるま（プラスで複数あるとき）。null なら最初の現役。
 String? get widgetDarumaId;/// 日付の境界（0〜3時を前日扱いにするなら 3）。仮置きは 0。
 int get dayShiftHours;
/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppSettingsCopyWith<AppSettings> get copyWith => _$AppSettingsCopyWithImpl<AppSettings>(this as AppSettings, _$identity);

  /// Serializes this AppSettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AppSettings;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppSettings&&(identical(other.reminderEnabled, _this.reminderEnabled) || other.reminderEnabled == _this.reminderEnabled)&&(identical(other.reminderMinuteOfDay, _this.reminderMinuteOfDay) || other.reminderMinuteOfDay == _this.reminderMinuteOfDay)&&(identical(other.eyeSideDefault, _this.eyeSideDefault) || other.eyeSideDefault == _this.eyeSideDefault)&&(identical(other.widgetStyle, _this.widgetStyle) || other.widgetStyle == _this.widgetStyle)&&(identical(other.onboardingDone, _this.onboardingDone) || other.onboardingDone == _this.onboardingDone)&&const DeepCollectionEquality().equals(other.reviewPromptedOn, _this.reviewPromptedOn)&&(identical(other.widgetDarumaId, _this.widgetDarumaId) || other.widgetDarumaId == _this.widgetDarumaId)&&(identical(other.dayShiftHours, _this.dayShiftHours) || other.dayShiftHours == _this.dayShiftHours));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AppSettings;
  return Object.hash(runtimeType,_this.reminderEnabled,_this.reminderMinuteOfDay,_this.eyeSideDefault,_this.widgetStyle,_this.onboardingDone,const DeepCollectionEquality().hash(_this.reviewPromptedOn),_this.widgetDarumaId,_this.dayShiftHours);
}

@override
String toString() {
  final _this = this as AppSettings;
  return 'AppSettings(reminderEnabled: ${_this.reminderEnabled}, reminderMinuteOfDay: ${_this.reminderMinuteOfDay}, eyeSideDefault: ${_this.eyeSideDefault}, widgetStyle: ${_this.widgetStyle}, onboardingDone: ${_this.onboardingDone}, reviewPromptedOn: ${_this.reviewPromptedOn}, widgetDarumaId: ${_this.widgetDarumaId}, dayShiftHours: ${_this.dayShiftHours})';
}


}

/// @nodoc
abstract mixin class $AppSettingsCopyWith<$Res>  {
  factory $AppSettingsCopyWith(AppSettings value, $Res Function(AppSettings) _then) = _$AppSettingsCopyWithImpl;
@useResult
$Res call({
 bool reminderEnabled, int reminderMinuteOfDay, EyeSide eyeSideDefault, WidgetStyle widgetStyle, bool onboardingDone, List<LocalDate> reviewPromptedOn, String? widgetDarumaId, int dayShiftHours
});




}
/// @nodoc
class _$AppSettingsCopyWithImpl<$Res>
    implements $AppSettingsCopyWith<$Res> {
  _$AppSettingsCopyWithImpl(this._self, this._then);

  final AppSettings _self;
  final $Res Function(AppSettings) _then;

/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? reminderEnabled = null,Object? reminderMinuteOfDay = null,Object? eyeSideDefault = null,Object? widgetStyle = null,Object? onboardingDone = null,Object? reviewPromptedOn = null,Object? widgetDarumaId = freezed,Object? dayShiftHours = null,}) {
  return _then(AppSettings(
reminderEnabled: null == reminderEnabled ? _self.reminderEnabled : reminderEnabled // ignore: cast_nullable_to_non_nullable
as bool,reminderMinuteOfDay: null == reminderMinuteOfDay ? _self.reminderMinuteOfDay : reminderMinuteOfDay // ignore: cast_nullable_to_non_nullable
as int,eyeSideDefault: null == eyeSideDefault ? _self.eyeSideDefault : eyeSideDefault // ignore: cast_nullable_to_non_nullable
as EyeSide,widgetStyle: null == widgetStyle ? _self.widgetStyle : widgetStyle // ignore: cast_nullable_to_non_nullable
as WidgetStyle,onboardingDone: null == onboardingDone ? _self.onboardingDone : onboardingDone // ignore: cast_nullable_to_non_nullable
as bool,reviewPromptedOn: null == reviewPromptedOn ? _self.reviewPromptedOn : reviewPromptedOn // ignore: cast_nullable_to_non_nullable
as List<LocalDate>,widgetDarumaId: freezed == widgetDarumaId ? _self.widgetDarumaId : widgetDarumaId // ignore: cast_nullable_to_non_nullable
as String?,dayShiftHours: null == dayShiftHours ? _self.dayShiftHours : dayShiftHours // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [AppSettings].
extension AppSettingsPatterns on AppSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppSettings value)  $default,){
final _that = this;
switch (_that) {
case _AppSettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppSettings value)?  $default,){
final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool reminderEnabled,  int reminderMinuteOfDay,  EyeSide eyeSideDefault,  WidgetStyle widgetStyle,  bool onboardingDone,  List<LocalDate> reviewPromptedOn,  String? widgetDarumaId,  int dayShiftHours)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
return $default(_that.reminderEnabled,_that.reminderMinuteOfDay,_that.eyeSideDefault,_that.widgetStyle,_that.onboardingDone,_that.reviewPromptedOn,_that.widgetDarumaId,_that.dayShiftHours);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool reminderEnabled,  int reminderMinuteOfDay,  EyeSide eyeSideDefault,  WidgetStyle widgetStyle,  bool onboardingDone,  List<LocalDate> reviewPromptedOn,  String? widgetDarumaId,  int dayShiftHours)  $default,) {final _that = this;
switch (_that) {
case _AppSettings():
return $default(_that.reminderEnabled,_that.reminderMinuteOfDay,_that.eyeSideDefault,_that.widgetStyle,_that.onboardingDone,_that.reviewPromptedOn,_that.widgetDarumaId,_that.dayShiftHours);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool reminderEnabled,  int reminderMinuteOfDay,  EyeSide eyeSideDefault,  WidgetStyle widgetStyle,  bool onboardingDone,  List<LocalDate> reviewPromptedOn,  String? widgetDarumaId,  int dayShiftHours)?  $default,) {final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
return $default(_that.reminderEnabled,_that.reminderMinuteOfDay,_that.eyeSideDefault,_that.widgetStyle,_that.onboardingDone,_that.reviewPromptedOn,_that.widgetDarumaId,_that.dayShiftHours);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AppSettings extends AppSettings {
  const _AppSettings({this.reminderEnabled = false, this.reminderMinuteOfDay = 20 * 60, this.eyeSideDefault = EyeSide.left, this.widgetStyle = WidgetStyle.paper, this.onboardingDone = false,  List<LocalDate> reviewPromptedOn = const <LocalDate>[], this.widgetDarumaId, this.dayShiftHours = 0}): _reviewPromptedOn = reviewPromptedOn,super._();
  factory _AppSettings.fromJson(Map<String, dynamic> json) => _$AppSettingsFromJson(json);

/// リマインド通知。既定オフ。
@override@JsonKey() final  bool reminderEnabled;
/// 通知時刻（0時からの分）。既定 20:00。
@override@JsonKey() final  int reminderMinuteOfDay;
@override@JsonKey() final  EyeSide eyeSideDefault;
@override@JsonKey() final  WidgetStyle widgetStyle;
@override@JsonKey() final  bool onboardingDone;
/// 評価依頼を出した日。365日3回まで。
 final  List<LocalDate> _reviewPromptedOn;
/// 評価依頼を出した日。365日3回まで。
@override@JsonKey() List<LocalDate> get reviewPromptedOn {
  if (_reviewPromptedOn is EqualUnmodifiableListView) return _reviewPromptedOn;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_reviewPromptedOn);
}

/// ウィジェットに出すだるま（プラスで複数あるとき）。null なら最初の現役。
@override final  String? widgetDarumaId;
/// 日付の境界（0〜3時を前日扱いにするなら 3）。仮置きは 0。
@override@JsonKey() final  int dayShiftHours;

/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppSettingsCopyWith<_AppSettings> get copyWith => __$AppSettingsCopyWithImpl<_AppSettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppSettingsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppSettings&&(identical(other.reminderEnabled, reminderEnabled) || other.reminderEnabled == reminderEnabled)&&(identical(other.reminderMinuteOfDay, reminderMinuteOfDay) || other.reminderMinuteOfDay == reminderMinuteOfDay)&&(identical(other.eyeSideDefault, eyeSideDefault) || other.eyeSideDefault == eyeSideDefault)&&(identical(other.widgetStyle, widgetStyle) || other.widgetStyle == widgetStyle)&&(identical(other.onboardingDone, onboardingDone) || other.onboardingDone == onboardingDone)&&const DeepCollectionEquality().equals(other.reviewPromptedOn, _reviewPromptedOn)&&(identical(other.widgetDarumaId, widgetDarumaId) || other.widgetDarumaId == widgetDarumaId)&&(identical(other.dayShiftHours, dayShiftHours) || other.dayShiftHours == dayShiftHours));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,reminderEnabled,reminderMinuteOfDay,eyeSideDefault,widgetStyle,onboardingDone,const DeepCollectionEquality().hash(_reviewPromptedOn),widgetDarumaId,dayShiftHours);
}

@override
String toString() {
    return 'AppSettings(reminderEnabled: $reminderEnabled, reminderMinuteOfDay: $reminderMinuteOfDay, eyeSideDefault: $eyeSideDefault, widgetStyle: $widgetStyle, onboardingDone: $onboardingDone, reviewPromptedOn: $reviewPromptedOn, widgetDarumaId: $widgetDarumaId, dayShiftHours: $dayShiftHours)';
}


}

/// @nodoc
abstract mixin class _$AppSettingsCopyWith<$Res> implements $AppSettingsCopyWith<$Res> {
  factory _$AppSettingsCopyWith(_AppSettings value, $Res Function(_AppSettings) _then) = __$AppSettingsCopyWithImpl;
@override @useResult
$Res call({
 bool reminderEnabled, int reminderMinuteOfDay, EyeSide eyeSideDefault, WidgetStyle widgetStyle, bool onboardingDone, List<LocalDate> reviewPromptedOn, String? widgetDarumaId, int dayShiftHours
});




}
/// @nodoc
class __$AppSettingsCopyWithImpl<$Res>
    implements _$AppSettingsCopyWith<$Res> {
  __$AppSettingsCopyWithImpl(this._self, this._then);

  final _AppSettings _self;
  final $Res Function(_AppSettings) _then;

/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? reminderEnabled = null,Object? reminderMinuteOfDay = null,Object? eyeSideDefault = null,Object? widgetStyle = null,Object? onboardingDone = null,Object? reviewPromptedOn = null,Object? widgetDarumaId = freezed,Object? dayShiftHours = null,}) {
  return _then(_AppSettings(
reminderEnabled: null == reminderEnabled ? _self.reminderEnabled : reminderEnabled // ignore: cast_nullable_to_non_nullable
as bool,reminderMinuteOfDay: null == reminderMinuteOfDay ? _self.reminderMinuteOfDay : reminderMinuteOfDay // ignore: cast_nullable_to_non_nullable
as int,eyeSideDefault: null == eyeSideDefault ? _self.eyeSideDefault : eyeSideDefault // ignore: cast_nullable_to_non_nullable
as EyeSide,widgetStyle: null == widgetStyle ? _self.widgetStyle : widgetStyle // ignore: cast_nullable_to_non_nullable
as WidgetStyle,onboardingDone: null == onboardingDone ? _self.onboardingDone : onboardingDone // ignore: cast_nullable_to_non_nullable
as bool,reviewPromptedOn: null == reviewPromptedOn ? _self._reviewPromptedOn : reviewPromptedOn // ignore: cast_nullable_to_non_nullable
as List<LocalDate>,widgetDarumaId: freezed == widgetDarumaId ? _self.widgetDarumaId : widgetDarumaId // ignore: cast_nullable_to_non_nullable
as String?,dayShiftHours: null == dayShiftHours ? _self.dayShiftHours : dayShiftHours // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$ExamPreset {

 String get id; String get name; LocalDate get date;/// 区分：university / highschool / juniorhigh / certification
 String get kind; String? get region; String get sourceUrl; String get sourceOrg; LocalDate get updatedOn; String get note;
/// Create a copy of ExamPreset
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExamPresetCopyWith<ExamPreset> get copyWith => _$ExamPresetCopyWithImpl<ExamPreset>(this as ExamPreset, _$identity);

  /// Serializes this ExamPreset to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ExamPreset;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExamPreset&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.date, _this.date) || other.date == _this.date)&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.region, _this.region) || other.region == _this.region)&&(identical(other.sourceUrl, _this.sourceUrl) || other.sourceUrl == _this.sourceUrl)&&(identical(other.sourceOrg, _this.sourceOrg) || other.sourceOrg == _this.sourceOrg)&&(identical(other.updatedOn, _this.updatedOn) || other.updatedOn == _this.updatedOn)&&(identical(other.note, _this.note) || other.note == _this.note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ExamPreset;
  return Object.hash(runtimeType,_this.id,_this.name,_this.date,_this.kind,_this.region,_this.sourceUrl,_this.sourceOrg,_this.updatedOn,_this.note);
}

@override
String toString() {
  final _this = this as ExamPreset;
  return 'ExamPreset(id: ${_this.id}, name: ${_this.name}, date: ${_this.date}, kind: ${_this.kind}, region: ${_this.region}, sourceUrl: ${_this.sourceUrl}, sourceOrg: ${_this.sourceOrg}, updatedOn: ${_this.updatedOn}, note: ${_this.note})';
}


}

/// @nodoc
abstract mixin class $ExamPresetCopyWith<$Res>  {
  factory $ExamPresetCopyWith(ExamPreset value, $Res Function(ExamPreset) _then) = _$ExamPresetCopyWithImpl;
@useResult
$Res call({
 String id, String name, LocalDate date, String kind, String? region, String sourceUrl, String sourceOrg, LocalDate updatedOn, String note
});




}
/// @nodoc
class _$ExamPresetCopyWithImpl<$Res>
    implements $ExamPresetCopyWith<$Res> {
  _$ExamPresetCopyWithImpl(this._self, this._then);

  final ExamPreset _self;
  final $Res Function(ExamPreset) _then;

/// Create a copy of ExamPreset
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? date = null,Object? kind = null,Object? region = freezed,Object? sourceUrl = null,Object? sourceOrg = null,Object? updatedOn = null,Object? note = null,}) {
  return _then(ExamPreset(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as LocalDate,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,region: freezed == region ? _self.region : region // ignore: cast_nullable_to_non_nullable
as String?,sourceUrl: null == sourceUrl ? _self.sourceUrl : sourceUrl // ignore: cast_nullable_to_non_nullable
as String,sourceOrg: null == sourceOrg ? _self.sourceOrg : sourceOrg // ignore: cast_nullable_to_non_nullable
as String,updatedOn: null == updatedOn ? _self.updatedOn : updatedOn // ignore: cast_nullable_to_non_nullable
as LocalDate,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ExamPreset].
extension ExamPresetPatterns on ExamPreset {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExamPreset value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExamPreset() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExamPreset value)  $default,){
final _that = this;
switch (_that) {
case _ExamPreset():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExamPreset value)?  $default,){
final _that = this;
switch (_that) {
case _ExamPreset() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  LocalDate date,  String kind,  String? region,  String sourceUrl,  String sourceOrg,  LocalDate updatedOn,  String note)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExamPreset() when $default != null:
return $default(_that.id,_that.name,_that.date,_that.kind,_that.region,_that.sourceUrl,_that.sourceOrg,_that.updatedOn,_that.note);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  LocalDate date,  String kind,  String? region,  String sourceUrl,  String sourceOrg,  LocalDate updatedOn,  String note)  $default,) {final _that = this;
switch (_that) {
case _ExamPreset():
return $default(_that.id,_that.name,_that.date,_that.kind,_that.region,_that.sourceUrl,_that.sourceOrg,_that.updatedOn,_that.note);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  LocalDate date,  String kind,  String? region,  String sourceUrl,  String sourceOrg,  LocalDate updatedOn,  String note)?  $default,) {final _that = this;
switch (_that) {
case _ExamPreset() when $default != null:
return $default(_that.id,_that.name,_that.date,_that.kind,_that.region,_that.sourceUrl,_that.sourceOrg,_that.updatedOn,_that.note);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ExamPreset extends ExamPreset {
  const _ExamPreset({required this.id, required this.name, required this.date, required this.kind, this.region, required this.sourceUrl, required this.sourceOrg, required this.updatedOn, this.note = ''}): super._();
  factory _ExamPreset.fromJson(Map<String, dynamic> json) => _$ExamPresetFromJson(json);

@override final  String id;
@override final  String name;
@override final  LocalDate date;
/// 区分：university / highschool / juniorhigh / certification
@override final  String kind;
@override final  String? region;
@override final  String sourceUrl;
@override final  String sourceOrg;
@override final  LocalDate updatedOn;
@override@JsonKey() final  String note;

/// Create a copy of ExamPreset
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExamPresetCopyWith<_ExamPreset> get copyWith => __$ExamPresetCopyWithImpl<_ExamPreset>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExamPresetToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExamPreset&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.date, date) || other.date == date)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.region, region) || other.region == region)&&(identical(other.sourceUrl, sourceUrl) || other.sourceUrl == sourceUrl)&&(identical(other.sourceOrg, sourceOrg) || other.sourceOrg == sourceOrg)&&(identical(other.updatedOn, updatedOn) || other.updatedOn == updatedOn)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,date,kind,region,sourceUrl,sourceOrg,updatedOn,note);
}

@override
String toString() {
    return 'ExamPreset(id: $id, name: $name, date: $date, kind: $kind, region: $region, sourceUrl: $sourceUrl, sourceOrg: $sourceOrg, updatedOn: $updatedOn, note: $note)';
}


}

/// @nodoc
abstract mixin class _$ExamPresetCopyWith<$Res> implements $ExamPresetCopyWith<$Res> {
  factory _$ExamPresetCopyWith(_ExamPreset value, $Res Function(_ExamPreset) _then) = __$ExamPresetCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, LocalDate date, String kind, String? region, String sourceUrl, String sourceOrg, LocalDate updatedOn, String note
});




}
/// @nodoc
class __$ExamPresetCopyWithImpl<$Res>
    implements _$ExamPresetCopyWith<$Res> {
  __$ExamPresetCopyWithImpl(this._self, this._then);

  final _ExamPreset _self;
  final $Res Function(_ExamPreset) _then;

/// Create a copy of ExamPreset
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? date = null,Object? kind = null,Object? region = freezed,Object? sourceUrl = null,Object? sourceOrg = null,Object? updatedOn = null,Object? note = null,}) {
  return _then(_ExamPreset(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as LocalDate,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,region: freezed == region ? _self.region : region // ignore: cast_nullable_to_non_nullable
as String?,sourceUrl: null == sourceUrl ? _self.sourceUrl : sourceUrl // ignore: cast_nullable_to_non_nullable
as String,sourceOrg: null == sourceOrg ? _self.sourceOrg : sourceOrg // ignore: cast_nullable_to_non_nullable
as String,updatedOn: null == updatedOn ? _self.updatedOn : updatedOn // ignore: cast_nullable_to_non_nullable
as LocalDate,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$PresetCatalog {

 int get version; LocalDate get updatedOn; List<ExamPreset> get presets;
/// Create a copy of PresetCatalog
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PresetCatalogCopyWith<PresetCatalog> get copyWith => _$PresetCatalogCopyWithImpl<PresetCatalog>(this as PresetCatalog, _$identity);

  /// Serializes this PresetCatalog to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PresetCatalog;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PresetCatalog&&(identical(other.version, _this.version) || other.version == _this.version)&&(identical(other.updatedOn, _this.updatedOn) || other.updatedOn == _this.updatedOn)&&const DeepCollectionEquality().equals(other.presets, _this.presets));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PresetCatalog;
  return Object.hash(runtimeType,_this.version,_this.updatedOn,const DeepCollectionEquality().hash(_this.presets));
}

@override
String toString() {
  final _this = this as PresetCatalog;
  return 'PresetCatalog(version: ${_this.version}, updatedOn: ${_this.updatedOn}, presets: ${_this.presets})';
}


}

/// @nodoc
abstract mixin class $PresetCatalogCopyWith<$Res>  {
  factory $PresetCatalogCopyWith(PresetCatalog value, $Res Function(PresetCatalog) _then) = _$PresetCatalogCopyWithImpl;
@useResult
$Res call({
 int version, LocalDate updatedOn, List<ExamPreset> presets
});




}
/// @nodoc
class _$PresetCatalogCopyWithImpl<$Res>
    implements $PresetCatalogCopyWith<$Res> {
  _$PresetCatalogCopyWithImpl(this._self, this._then);

  final PresetCatalog _self;
  final $Res Function(PresetCatalog) _then;

/// Create a copy of PresetCatalog
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? version = null,Object? updatedOn = null,Object? presets = null,}) {
  return _then(PresetCatalog(
version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,updatedOn: null == updatedOn ? _self.updatedOn : updatedOn // ignore: cast_nullable_to_non_nullable
as LocalDate,presets: null == presets ? _self.presets : presets // ignore: cast_nullable_to_non_nullable
as List<ExamPreset>,
  ));
}

}


/// Adds pattern-matching-related methods to [PresetCatalog].
extension PresetCatalogPatterns on PresetCatalog {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PresetCatalog value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PresetCatalog() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PresetCatalog value)  $default,){
final _that = this;
switch (_that) {
case _PresetCatalog():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PresetCatalog value)?  $default,){
final _that = this;
switch (_that) {
case _PresetCatalog() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int version,  LocalDate updatedOn,  List<ExamPreset> presets)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PresetCatalog() when $default != null:
return $default(_that.version,_that.updatedOn,_that.presets);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int version,  LocalDate updatedOn,  List<ExamPreset> presets)  $default,) {final _that = this;
switch (_that) {
case _PresetCatalog():
return $default(_that.version,_that.updatedOn,_that.presets);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int version,  LocalDate updatedOn,  List<ExamPreset> presets)?  $default,) {final _that = this;
switch (_that) {
case _PresetCatalog() when $default != null:
return $default(_that.version,_that.updatedOn,_that.presets);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PresetCatalog extends PresetCatalog {
  const _PresetCatalog({required this.version, required this.updatedOn, required  List<ExamPreset> presets}): _presets = presets,super._();
  factory _PresetCatalog.fromJson(Map<String, dynamic> json) => _$PresetCatalogFromJson(json);

@override final  int version;
@override final  LocalDate updatedOn;
 final  List<ExamPreset> _presets;
@override List<ExamPreset> get presets {
  if (_presets is EqualUnmodifiableListView) return _presets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_presets);
}


/// Create a copy of PresetCatalog
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PresetCatalogCopyWith<_PresetCatalog> get copyWith => __$PresetCatalogCopyWithImpl<_PresetCatalog>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PresetCatalogToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PresetCatalog&&(identical(other.version, version) || other.version == version)&&(identical(other.updatedOn, updatedOn) || other.updatedOn == updatedOn)&&const DeepCollectionEquality().equals(other.presets, _presets));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,version,updatedOn,const DeepCollectionEquality().hash(_presets));
}

@override
String toString() {
    return 'PresetCatalog(version: $version, updatedOn: $updatedOn, presets: $presets)';
}


}

/// @nodoc
abstract mixin class _$PresetCatalogCopyWith<$Res> implements $PresetCatalogCopyWith<$Res> {
  factory _$PresetCatalogCopyWith(_PresetCatalog value, $Res Function(_PresetCatalog) _then) = __$PresetCatalogCopyWithImpl;
@override @useResult
$Res call({
 int version, LocalDate updatedOn, List<ExamPreset> presets
});




}
/// @nodoc
class __$PresetCatalogCopyWithImpl<$Res>
    implements _$PresetCatalogCopyWith<$Res> {
  __$PresetCatalogCopyWithImpl(this._self, this._then);

  final _PresetCatalog _self;
  final $Res Function(_PresetCatalog) _then;

/// Create a copy of PresetCatalog
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? version = null,Object? updatedOn = null,Object? presets = null,}) {
  return _then(_PresetCatalog(
version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,updatedOn: null == updatedOn ? _self.updatedOn : updatedOn // ignore: cast_nullable_to_non_nullable
as LocalDate,presets: null == presets ? _self._presets : presets // ignore: cast_nullable_to_non_nullable
as List<ExamPreset>,
  ));
}


}


/// @nodoc
mixin _$WidgetSnapshot {

 DarumaLook get look; String get name; String? get deadlineName;/// 今日から14日分。各日の0時に切り替える。
 List<TimelineEntry> get timeline; DateTime get generatedAt; WidgetStyle get style;
/// Create a copy of WidgetSnapshot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WidgetSnapshotCopyWith<WidgetSnapshot> get copyWith => _$WidgetSnapshotCopyWithImpl<WidgetSnapshot>(this as WidgetSnapshot, _$identity);

  /// Serializes this WidgetSnapshot to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as WidgetSnapshot;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WidgetSnapshot&&(identical(other.look, _this.look) || other.look == _this.look)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.deadlineName, _this.deadlineName) || other.deadlineName == _this.deadlineName)&&const DeepCollectionEquality().equals(other.timeline, _this.timeline)&&(identical(other.generatedAt, _this.generatedAt) || other.generatedAt == _this.generatedAt)&&(identical(other.style, _this.style) || other.style == _this.style));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as WidgetSnapshot;
  return Object.hash(runtimeType,_this.look,_this.name,_this.deadlineName,const DeepCollectionEquality().hash(_this.timeline),_this.generatedAt,_this.style);
}

@override
String toString() {
  final _this = this as WidgetSnapshot;
  return 'WidgetSnapshot(look: ${_this.look}, name: ${_this.name}, deadlineName: ${_this.deadlineName}, timeline: ${_this.timeline}, generatedAt: ${_this.generatedAt}, style: ${_this.style})';
}


}

/// @nodoc
abstract mixin class $WidgetSnapshotCopyWith<$Res>  {
  factory $WidgetSnapshotCopyWith(WidgetSnapshot value, $Res Function(WidgetSnapshot) _then) = _$WidgetSnapshotCopyWithImpl;
@useResult
$Res call({
 DarumaLook look, String name, String? deadlineName, List<TimelineEntry> timeline, DateTime generatedAt, WidgetStyle style
});


$DarumaLookCopyWith<$Res> get look;

}
/// @nodoc
class _$WidgetSnapshotCopyWithImpl<$Res>
    implements $WidgetSnapshotCopyWith<$Res> {
  _$WidgetSnapshotCopyWithImpl(this._self, this._then);

  final WidgetSnapshot _self;
  final $Res Function(WidgetSnapshot) _then;

/// Create a copy of WidgetSnapshot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? look = null,Object? name = null,Object? deadlineName = freezed,Object? timeline = null,Object? generatedAt = null,Object? style = null,}) {
  return _then(WidgetSnapshot(
look: null == look ? _self.look : look // ignore: cast_nullable_to_non_nullable
as DarumaLook,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,deadlineName: freezed == deadlineName ? _self.deadlineName : deadlineName // ignore: cast_nullable_to_non_nullable
as String?,timeline: null == timeline ? _self.timeline : timeline // ignore: cast_nullable_to_non_nullable
as List<TimelineEntry>,generatedAt: null == generatedAt ? _self.generatedAt : generatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,style: null == style ? _self.style : style // ignore: cast_nullable_to_non_nullable
as WidgetStyle,
  ));
}
/// Create a copy of WidgetSnapshot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DarumaLookCopyWith<$Res> get look {
  
  return $DarumaLookCopyWith<$Res>(_self.look, (value) {
    return _then(_self.copyWith(look: value));
  });
}
}


/// Adds pattern-matching-related methods to [WidgetSnapshot].
extension WidgetSnapshotPatterns on WidgetSnapshot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WidgetSnapshot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WidgetSnapshot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WidgetSnapshot value)  $default,){
final _that = this;
switch (_that) {
case _WidgetSnapshot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WidgetSnapshot value)?  $default,){
final _that = this;
switch (_that) {
case _WidgetSnapshot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DarumaLook look,  String name,  String? deadlineName,  List<TimelineEntry> timeline,  DateTime generatedAt,  WidgetStyle style)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WidgetSnapshot() when $default != null:
return $default(_that.look,_that.name,_that.deadlineName,_that.timeline,_that.generatedAt,_that.style);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DarumaLook look,  String name,  String? deadlineName,  List<TimelineEntry> timeline,  DateTime generatedAt,  WidgetStyle style)  $default,) {final _that = this;
switch (_that) {
case _WidgetSnapshot():
return $default(_that.look,_that.name,_that.deadlineName,_that.timeline,_that.generatedAt,_that.style);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DarumaLook look,  String name,  String? deadlineName,  List<TimelineEntry> timeline,  DateTime generatedAt,  WidgetStyle style)?  $default,) {final _that = this;
switch (_that) {
case _WidgetSnapshot() when $default != null:
return $default(_that.look,_that.name,_that.deadlineName,_that.timeline,_that.generatedAt,_that.style);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WidgetSnapshot implements WidgetSnapshot {
  const _WidgetSnapshot({required this.look, required this.name, this.deadlineName, required  List<TimelineEntry> timeline, required this.generatedAt, required this.style}): _timeline = timeline;
  factory _WidgetSnapshot.fromJson(Map<String, dynamic> json) => _$WidgetSnapshotFromJson(json);

@override final  DarumaLook look;
@override final  String name;
@override final  String? deadlineName;
/// 今日から14日分。各日の0時に切り替える。
 final  List<TimelineEntry> _timeline;
/// 今日から14日分。各日の0時に切り替える。
@override List<TimelineEntry> get timeline {
  if (_timeline is EqualUnmodifiableListView) return _timeline;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_timeline);
}

@override final  DateTime generatedAt;
@override final  WidgetStyle style;

/// Create a copy of WidgetSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WidgetSnapshotCopyWith<_WidgetSnapshot> get copyWith => __$WidgetSnapshotCopyWithImpl<_WidgetSnapshot>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WidgetSnapshotToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _WidgetSnapshot&&(identical(other.look, look) || other.look == look)&&(identical(other.name, name) || other.name == name)&&(identical(other.deadlineName, deadlineName) || other.deadlineName == deadlineName)&&const DeepCollectionEquality().equals(other.timeline, _timeline)&&(identical(other.generatedAt, generatedAt) || other.generatedAt == generatedAt)&&(identical(other.style, style) || other.style == style));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,look,name,deadlineName,const DeepCollectionEquality().hash(_timeline),generatedAt,style);
}

@override
String toString() {
    return 'WidgetSnapshot(look: $look, name: $name, deadlineName: $deadlineName, timeline: $timeline, generatedAt: $generatedAt, style: $style)';
}


}

/// @nodoc
abstract mixin class _$WidgetSnapshotCopyWith<$Res> implements $WidgetSnapshotCopyWith<$Res> {
  factory _$WidgetSnapshotCopyWith(_WidgetSnapshot value, $Res Function(_WidgetSnapshot) _then) = __$WidgetSnapshotCopyWithImpl;
@override @useResult
$Res call({
 DarumaLook look, String name, String? deadlineName, List<TimelineEntry> timeline, DateTime generatedAt, WidgetStyle style
});


@override $DarumaLookCopyWith<$Res> get look;

}
/// @nodoc
class __$WidgetSnapshotCopyWithImpl<$Res>
    implements _$WidgetSnapshotCopyWith<$Res> {
  __$WidgetSnapshotCopyWithImpl(this._self, this._then);

  final _WidgetSnapshot _self;
  final $Res Function(_WidgetSnapshot) _then;

/// Create a copy of WidgetSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? look = null,Object? name = null,Object? deadlineName = freezed,Object? timeline = null,Object? generatedAt = null,Object? style = null,}) {
  return _then(_WidgetSnapshot(
look: null == look ? _self.look : look // ignore: cast_nullable_to_non_nullable
as DarumaLook,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,deadlineName: freezed == deadlineName ? _self.deadlineName : deadlineName // ignore: cast_nullable_to_non_nullable
as String?,timeline: null == timeline ? _self._timeline : timeline // ignore: cast_nullable_to_non_nullable
as List<TimelineEntry>,generatedAt: null == generatedAt ? _self.generatedAt : generatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,style: null == style ? _self.style : style // ignore: cast_nullable_to_non_nullable
as WidgetStyle,
  ));
}

/// Create a copy of WidgetSnapshot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DarumaLookCopyWith<$Res> get look {
  
  return $DarumaLookCopyWith<$Res>(_self.look, (value) {
    return _then(_self.copyWith(look: value));
  });
}
}


/// @nodoc
mixin _$BackupData {

 int get version; DateTime get exportedAt; List<Daruma> get darumas; List<Milestone> get milestones; List<Checkin> get checkins; List<Recovery> get recoveries; AppSettings? get settings;
/// Create a copy of BackupData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BackupDataCopyWith<BackupData> get copyWith => _$BackupDataCopyWithImpl<BackupData>(this as BackupData, _$identity);

  /// Serializes this BackupData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as BackupData;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BackupData&&(identical(other.version, _this.version) || other.version == _this.version)&&(identical(other.exportedAt, _this.exportedAt) || other.exportedAt == _this.exportedAt)&&const DeepCollectionEquality().equals(other.darumas, _this.darumas)&&const DeepCollectionEquality().equals(other.milestones, _this.milestones)&&const DeepCollectionEquality().equals(other.checkins, _this.checkins)&&const DeepCollectionEquality().equals(other.recoveries, _this.recoveries)&&(identical(other.settings, _this.settings) || other.settings == _this.settings));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as BackupData;
  return Object.hash(runtimeType,_this.version,_this.exportedAt,const DeepCollectionEquality().hash(_this.darumas),const DeepCollectionEquality().hash(_this.milestones),const DeepCollectionEquality().hash(_this.checkins),const DeepCollectionEquality().hash(_this.recoveries),_this.settings);
}

@override
String toString() {
  final _this = this as BackupData;
  return 'BackupData(version: ${_this.version}, exportedAt: ${_this.exportedAt}, darumas: ${_this.darumas}, milestones: ${_this.milestones}, checkins: ${_this.checkins}, recoveries: ${_this.recoveries}, settings: ${_this.settings})';
}


}

/// @nodoc
abstract mixin class $BackupDataCopyWith<$Res>  {
  factory $BackupDataCopyWith(BackupData value, $Res Function(BackupData) _then) = _$BackupDataCopyWithImpl;
@useResult
$Res call({
 int version, DateTime exportedAt, List<Daruma> darumas, List<Milestone> milestones, List<Checkin> checkins, List<Recovery> recoveries, AppSettings? settings
});


$AppSettingsCopyWith<$Res>? get settings;

}
/// @nodoc
class _$BackupDataCopyWithImpl<$Res>
    implements $BackupDataCopyWith<$Res> {
  _$BackupDataCopyWithImpl(this._self, this._then);

  final BackupData _self;
  final $Res Function(BackupData) _then;

/// Create a copy of BackupData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? version = null,Object? exportedAt = null,Object? darumas = null,Object? milestones = null,Object? checkins = null,Object? recoveries = null,Object? settings = freezed,}) {
  return _then(BackupData(
version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,exportedAt: null == exportedAt ? _self.exportedAt : exportedAt // ignore: cast_nullable_to_non_nullable
as DateTime,darumas: null == darumas ? _self.darumas : darumas // ignore: cast_nullable_to_non_nullable
as List<Daruma>,milestones: null == milestones ? _self.milestones : milestones // ignore: cast_nullable_to_non_nullable
as List<Milestone>,checkins: null == checkins ? _self.checkins : checkins // ignore: cast_nullable_to_non_nullable
as List<Checkin>,recoveries: null == recoveries ? _self.recoveries : recoveries // ignore: cast_nullable_to_non_nullable
as List<Recovery>,settings: freezed == settings ? _self.settings : settings // ignore: cast_nullable_to_non_nullable
as AppSettings?,
  ));
}
/// Create a copy of BackupData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AppSettingsCopyWith<$Res>? get settings {
    if (_self.settings == null) {
    return null;
  }

  return $AppSettingsCopyWith<$Res>(_self.settings!, (value) {
    return _then(_self.copyWith(settings: value));
  });
}
}


/// Adds pattern-matching-related methods to [BackupData].
extension BackupDataPatterns on BackupData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BackupData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BackupData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BackupData value)  $default,){
final _that = this;
switch (_that) {
case _BackupData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BackupData value)?  $default,){
final _that = this;
switch (_that) {
case _BackupData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int version,  DateTime exportedAt,  List<Daruma> darumas,  List<Milestone> milestones,  List<Checkin> checkins,  List<Recovery> recoveries,  AppSettings? settings)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BackupData() when $default != null:
return $default(_that.version,_that.exportedAt,_that.darumas,_that.milestones,_that.checkins,_that.recoveries,_that.settings);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int version,  DateTime exportedAt,  List<Daruma> darumas,  List<Milestone> milestones,  List<Checkin> checkins,  List<Recovery> recoveries,  AppSettings? settings)  $default,) {final _that = this;
switch (_that) {
case _BackupData():
return $default(_that.version,_that.exportedAt,_that.darumas,_that.milestones,_that.checkins,_that.recoveries,_that.settings);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int version,  DateTime exportedAt,  List<Daruma> darumas,  List<Milestone> milestones,  List<Checkin> checkins,  List<Recovery> recoveries,  AppSettings? settings)?  $default,) {final _that = this;
switch (_that) {
case _BackupData() when $default != null:
return $default(_that.version,_that.exportedAt,_that.darumas,_that.milestones,_that.checkins,_that.recoveries,_that.settings);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BackupData implements BackupData {
  const _BackupData({required this.version, required this.exportedAt, required  List<Daruma> darumas, required  List<Milestone> milestones, required  List<Checkin> checkins, required  List<Recovery> recoveries, this.settings}): _darumas = darumas,_milestones = milestones,_checkins = checkins,_recoveries = recoveries;
  factory _BackupData.fromJson(Map<String, dynamic> json) => _$BackupDataFromJson(json);

@override final  int version;
@override final  DateTime exportedAt;
 final  List<Daruma> _darumas;
@override List<Daruma> get darumas {
  if (_darumas is EqualUnmodifiableListView) return _darumas;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_darumas);
}

 final  List<Milestone> _milestones;
@override List<Milestone> get milestones {
  if (_milestones is EqualUnmodifiableListView) return _milestones;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_milestones);
}

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

@override final  AppSettings? settings;

/// Create a copy of BackupData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BackupDataCopyWith<_BackupData> get copyWith => __$BackupDataCopyWithImpl<_BackupData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BackupDataToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BackupData&&(identical(other.version, version) || other.version == version)&&(identical(other.exportedAt, exportedAt) || other.exportedAt == exportedAt)&&const DeepCollectionEquality().equals(other.darumas, _darumas)&&const DeepCollectionEquality().equals(other.milestones, _milestones)&&const DeepCollectionEquality().equals(other.checkins, _checkins)&&const DeepCollectionEquality().equals(other.recoveries, _recoveries)&&(identical(other.settings, settings) || other.settings == settings));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,version,exportedAt,const DeepCollectionEquality().hash(_darumas),const DeepCollectionEquality().hash(_milestones),const DeepCollectionEquality().hash(_checkins),const DeepCollectionEquality().hash(_recoveries),settings);
}

@override
String toString() {
    return 'BackupData(version: $version, exportedAt: $exportedAt, darumas: $darumas, milestones: $milestones, checkins: $checkins, recoveries: $recoveries, settings: $settings)';
}


}

/// @nodoc
abstract mixin class _$BackupDataCopyWith<$Res> implements $BackupDataCopyWith<$Res> {
  factory _$BackupDataCopyWith(_BackupData value, $Res Function(_BackupData) _then) = __$BackupDataCopyWithImpl;
@override @useResult
$Res call({
 int version, DateTime exportedAt, List<Daruma> darumas, List<Milestone> milestones, List<Checkin> checkins, List<Recovery> recoveries, AppSettings? settings
});


@override $AppSettingsCopyWith<$Res>? get settings;

}
/// @nodoc
class __$BackupDataCopyWithImpl<$Res>
    implements _$BackupDataCopyWith<$Res> {
  __$BackupDataCopyWithImpl(this._self, this._then);

  final _BackupData _self;
  final $Res Function(_BackupData) _then;

/// Create a copy of BackupData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? version = null,Object? exportedAt = null,Object? darumas = null,Object? milestones = null,Object? checkins = null,Object? recoveries = null,Object? settings = freezed,}) {
  return _then(_BackupData(
version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,exportedAt: null == exportedAt ? _self.exportedAt : exportedAt // ignore: cast_nullable_to_non_nullable
as DateTime,darumas: null == darumas ? _self._darumas : darumas // ignore: cast_nullable_to_non_nullable
as List<Daruma>,milestones: null == milestones ? _self._milestones : milestones // ignore: cast_nullable_to_non_nullable
as List<Milestone>,checkins: null == checkins ? _self._checkins : checkins // ignore: cast_nullable_to_non_nullable
as List<Checkin>,recoveries: null == recoveries ? _self._recoveries : recoveries // ignore: cast_nullable_to_non_nullable
as List<Recovery>,settings: freezed == settings ? _self.settings : settings // ignore: cast_nullable_to_non_nullable
as AppSettings?,
  ));
}

/// Create a copy of BackupData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AppSettingsCopyWith<$Res>? get settings {
    if (_self.settings == null) {
    return null;
  }

  return $AppSettingsCopyWith<$Res>(_self.settings!, (value) {
    return _then(_self.copyWith(settings: value));
  });
}
}

// dart format on
