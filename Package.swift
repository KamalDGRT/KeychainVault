// swift-tools-version:5.9
//
// Package.swift
// KeychainVault
//
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "KeychainVault",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "KeychainVault",
            targets: ["KeychainVault"]
        )
    ],
    targets: [
        .target(
            name: "KeychainVault",
            path: "Sources/KeychainVault" // Source files directory
        )
    ]
)
