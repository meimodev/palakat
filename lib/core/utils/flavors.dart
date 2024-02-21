// enum Flavor {
//   dev,
//   staging,
//   production,
// }
//
// class F {
//   static late Flavor flavor;
// }
//
// class FlavorConfig<T> {
//   const FlavorConfig({
//     required this.dev,
//     required this.staging,
//     required this.production,
//     this.fallback,
//   }) : assert(
//           dev == null || production == null ? fallback != null : true,
//           '[fallback]cannot be null if there is one flavor whose value is null',
//         );
//
//   final T? dev;
//   final T? staging;
//   final T? production;
//   final T? fallback;
//
//   T get value {
//     switch (F.flavor) {
//       case Flavor.dev:
//         return dev ?? fallback!;
//       case Flavor.staging:
//         return staging ?? fallback!;
//       case Flavor.production:
//         return production ?? fallback!;
//     }
//   }
// }
