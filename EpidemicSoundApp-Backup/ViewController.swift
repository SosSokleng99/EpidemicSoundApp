//
//  ViewController.swift
//  EpidemicSoundApp-Backup
//
//  Created by Danilo Rivera on 1/20/20.
//  Copyright © 2020 Danilo Rivera. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    //Custom Img
    let albumImg: CustomImg = {
        let view = CustomImg()
        view.image = UIImage(named: "Album_250x250")
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let playPauseBtn: UIButton = {
        let image = UIImage(named: "play-100") as UIImage?
        let button   = UIButton(type: UIButton.ButtonType.custom) as UIButton
        button.contentMode = .center
        button.setImage(image, for: [])
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(playPausedAction(_:)), for:.touchUpInside)
        return button
    }()
    
    let audioTitleLabel: UILabel = {
        let view    =   UILabel()
        view.text = "Welcome to Epidemic Sound"
        view.textColor  =  .white
        view.font   =   UIFont.boldSystemFont(ofSize: 18)
        view.textAlignment = .center
        view.numberOfLines = 2
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    let prevBtn: UIButton = {
        let image = UIImage(named: "prev-60") as UIImage?
        let button   = UIButton(type: UIButton.ButtonType.custom) as UIButton
        button.contentMode = .center
        button.setImage(image, for: [])
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(prevAction(_:)), for:.touchUpInside)
        return button
    }()
    
    let nextBtn: UIButton = {
        let image = UIImage(named: "next-60") as UIImage?
        let button   = UIButton(type: UIButton.ButtonType.custom) as UIButton
        button.contentMode = .center
        button.setImage(image, for: [])
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(nextAction(_:)), for:.touchUpInside)
        return button
    }()
    
    
    let partLabel: UILabel = {
        let view    =   UILabel()
        view.text = "1/10"
        view.textColor  =  .white
        view.font   =   UIFont.boldSystemFont(ofSize: 18)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    let timeLabel: UILabel = {
        let view    =   UILabel()
        view.text = "--:--"
        view.textColor  =  .white
        view.font   =   UIFont.boldSystemFont(ofSize: 15)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let currentTimeLabel: UILabel = {
        let view    =   UILabel()
        view.text = "--:--"
        view.textColor  =  .white
        view.font   =   UIFont.boldSystemFont(ofSize: 15)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let playRateBtn: UIButton = {
        let image = UIImage(named: "pause-50") as UIImage?
        let button   = UIButton(type: UIButton.ButtonType.custom) as UIButton
        button.contentMode = .center
        button.setImage(image, for: [])
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    
    let sliderAudio: UISlider = {
        let mySlider = UISlider()
        mySlider.value = 0
        mySlider.minimumValue = 0
        mySlider.maximumValue = 1
        mySlider.autoresizesSubviews = true
        
        mySlider.maximumTrackTintColor = .white
        mySlider.minimumTrackTintColor = .orange
        mySlider.setThumbImage(UIImage(named: "moon-24"), for: .normal)
        mySlider.translatesAutoresizingMaskIntoConstraints = false
        
        
        mySlider.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTappedSlider)))
        mySlider.addTarget(self, action: #selector(sliderValueDidChange(_:)), for: .valueChanged)
        return mySlider
    }()
    
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    
    var tracks = [Track]()
    
    var playlist: NSMutableArray = NSMutableArray()
    var titleList: NSMutableArray = NSMutableArray()
    var coverList: NSMutableArray = NSMutableArray()
    
    var timer: Timer?
    var index: Int = Int()
    var avPlayer: AVPlayer!
    var isPaused: Bool!
    
    
    
    


    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
        view.backgroundColor = UIColor.init(white: 1, alpha: 0.3)
        
        setupView()
        fetchTracks()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
        self.avPlayer = nil
        self.timer?.invalidate()
    }
    
    func fetchTracks() {
            FirFirestoreServices.shared.readTracks(from: .tracks, returning: Track.self) { (tracks) in
                self.tracks = tracks
                self.collectionView.reloadData()

                tracks.forEach { (track) in
                    
                    
                    
                    self.playlist.add(track.audio_url)
                    self.titleList.add(track.title)
                    self.coverList.add(track.album_cover)
                    
                    
                }
                
                //Load Cover Image
                guard let coverImage = self.coverList[self.index] as? String else {return}
                self.albumImg.locateURLImg(urlString: coverImage)
                
                //AudioTitle
                guard let audioTitle = self.titleList[self.index] as? String else {return}
                self.audioTitleLabel.text = audioTitle
                
                self.isPaused = false
                self.playPauseBtn.setImage(UIImage(named: "pause-100"), for: .normal)
                guard let audioUrlString = self.playlist[self.index] as? String else {return}
                
                
                
                guard let audioUrl = URL(string: audioUrlString) else {return}
                self.play(url: audioUrl)
                self.setUpTimer()
                

            }
        }
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    
    
    func play(url:URL) {
        self.avPlayer = AVPlayer(playerItem: AVPlayerItem(url: url))
        self.avPlayer.automaticallyWaitsToMinimizeStalling = false
        avPlayer!.volume = 1.0
        avPlayer.play()
    }



    func setUpTimer() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.didPlayEnd), name: .AVPlayerItemDidPlayToEndTime, object: nil)
        
        timer = Timer(timeInterval: 0.001, target: self, selector: #selector(ViewController.tick), userInfo: nil, repeats: true)
        RunLoop.current.add(timer!, forMode: .common)
        
    }

    @objc func didPlayEnd() {
        self.nextPlay()
    }
    
    @objc func tick() {
        
        if((avPlayer.currentItem?.asset.duration) != nil) {
            if let _ = avPlayer.currentItem?.asset.duration{}else{return}
            if let _ = avPlayer.currentItem?.currentTime(){}else{return}
            let currentTime1: CMTime = ((avPlayer.currentItem?.asset.duration)!)
            let seconds1: Float64 = CMTimeGetSeconds(currentTime1)
            let time1: Float = Float(seconds1)
            sliderAudio.minimumValue = 0
            sliderAudio.maximumValue = time1
            
            let currentTime: CMTime = (self.avPlayer.currentTime())
            let seconds: Float64 = CMTimeGetSeconds(currentTime)
            let time: Float = Float(seconds)
            self.sliderAudio.value = time
            
            timeLabel.text = self.formatTimeFromSeconds(totalSeconds: Int32(Float(Float64(CMTimeGetSeconds((self.avPlayer?.currentItem?.asset.duration)!)))))
            
            currentTimeLabel.text = self.formatTimeFromSeconds(totalSeconds: Int32(Float(Float64(CMTimeGetSeconds((self.avPlayer?.currentItem?.currentTime())!)))))
            
        }
        
        
        
        
    }

    //MARK: Audio Command

    @objc func playPausedAction(_ sender: Any) {
        self.togglePlayPaused()
    }

    func togglePlayPaused() {
        if avPlayer.timeControlStatus == .playing {
            playPauseBtn.setImage(UIImage(named: "play-100"), for: .normal)
            avPlayer.pause()
            isPaused = true
        } else {
            playPauseBtn.setImage(UIImage(named: "pause-100"), for: .normal)
            avPlayer.play()
            isPaused = false
        }
    }

    @objc func nextAction(_ sender: Any) {
        self.nextPlay()
    }
    
    @objc func prevAction(_ sender: Any) {
        
        self.previousPlay()
    }


    func nextPlay() {
        if(index < playlist.count - 1) {
            index = index + 1
            
            //Load Cover Image
            guard let coverImage = self.coverList[self.index] as? String else {return}
            self.albumImg.locateURLImg(urlString: coverImage)
            

            //AudioTitle
            guard let nextAudioTitle = self.titleList[self.index] as? String else {return}
            audioTitleLabel.text = nextAudioTitle
            
            
            let selectedIndexPath = NSIndexPath(item: index, section: 0)
            collectionView.selectItem(at: selectedIndexPath as IndexPath, animated: true, scrollPosition: [])
            collectionView.scrollToItem(at: selectedIndexPath as IndexPath, at: .centeredVertically, animated: true)
            isPaused = false
            playPauseBtn.setImage(UIImage(named: "pause-100"), for: .normal)
            self.play(url: URL(string: (playlist[self.index] as! String))!)
            
        } else {
            index = playlist.count - 1
            
            //Load Cover Image
            guard let coverImage = self.coverList[self.index] as? String else {return}
            self.albumImg.locateURLImg(urlString: coverImage)
            
            //AudioTitle
            guard let nextAudioTitle = self.titleList[self.index] as? String else {return}
            audioTitleLabel.text = nextAudioTitle
        
            isPaused = false
            playPauseBtn.setImage(UIImage(named: "pause-100"), for: .normal)
            self.play(url: URL(string: (playlist[self.index] as! String))!)
            
        }
    }
    
    
    func previousPlay() {
        if (index > 0) {
            index = index - 1
            
            //Load Cover Image
            guard let coverImage = self.coverList[self.index] as? String else {return}
            self.albumImg.locateURLImg(urlString: coverImage)
            
            //AudioTitle
            guard let nextAudioTitle = self.titleList[self.index] as? String else {return}
            audioTitleLabel.text = nextAudioTitle
            
            let selectedIndexPath = NSIndexPath(item: index, section: 0)
            collectionView.selectItem(at: selectedIndexPath as IndexPath, animated: true, scrollPosition: [])
            collectionView.scrollToItem(at: selectedIndexPath as IndexPath, at: .centeredVertically, animated: true)
            isPaused = false
            playPauseBtn.setImage(UIImage(named: "pause-100"), for: .normal)
            self.play(url: URL(string: (playlist[self.index] as! String))!)
        } else {
            index = 0
            
            //Load Cover Image
            guard let coverImage = self.coverList[self.index] as? String else {return}
            self.albumImg.locateURLImg(urlString: coverImage)
            
            //AudioTitle
            guard let nextAudioTitle = self.titleList[self.index] as? String else {return}
            audioTitleLabel.text = nextAudioTitle
            
            isPaused = false
            playPauseBtn.setImage(UIImage(named: "pause-100"), for: .normal)
            self.play(url: URL(string: (playlist[self.index] as! String))!)
        }
    }
    
    
    
    
    
    
    //MARK: HELPERS functions
    
    @objc func sliderValueDidChange(_ sender: UISlider)
    {
        
        let second: Int64 = Int64(sender.value)
        let targetTime: CMTime = CMTimeMake(value: second, timescale: 1)
        avPlayer.seek(to: targetTime)
    }
    
    @objc func didTappedSlider(_ sender: UITapGestureRecognizer) {
        if let slider = sender.view as? UISlider {
            if slider.isHighlighted { return }
            let point = sender.location(in: slider)
            let percentage = Float(point.x / slider.bounds.width)
            let delta = percentage * (slider.maximumValue - slider.minimumValue)
            let value = slider.minimumValue + delta
            slider.setValue(value, animated: false)
            let seconds : Int64 = Int64(value)
            let targetTime:CMTime = CMTimeMake(value: seconds, timescale: 1)
            avPlayer!.seek(to: targetTime)
        }
        
    }
    
    func playSelectedCell(cellIndexPath: Int) {
        index = cellIndexPath
        
        //Load Cover Image
        guard let coverImage = self.coverList[self.index] as? String else {return}
        self.albumImg.locateURLImg(urlString: coverImage)
        
        //AudioTitle
        guard let nextAudioTitle = self.titleList[self.index] as? String else {return}
        audioTitleLabel.text = nextAudioTitle
        
        let selectedIndexPath = NSIndexPath(item: index, section: 0)
        collectionView.selectItem(at: selectedIndexPath as IndexPath, animated: true, scrollPosition: [])
        collectionView.scrollToItem(at: selectedIndexPath as IndexPath, at: .centeredVertically, animated: true)
        isPaused = false
        playPauseBtn.setImage(UIImage(named: "pause-100"), for: .normal)
        self.play(url: URL(string: (playlist[self.index] as! String))!)
        
    }
    
    
    func setupView() {
        
        let timestackView = UIStackView(arrangedSubviews: [currentTimeLabel, timeLabel])
        timestackView.translatesAutoresizingMaskIntoConstraints = false
        timestackView.axis = .horizontal
        timestackView.distribution = .equalSpacing
        
        let ppnpStackView = UIStackView(arrangedSubviews: [prevBtn, playPauseBtn ,nextBtn])
        ppnpStackView.translatesAutoresizingMaskIntoConstraints = false
        ppnpStackView.axis = .horizontal
        ppnpStackView.distribution = .fillProportionally
        ppnpStackView.alignment = .center
        
        
        view.addSubview(albumImg)
        view.addSubview(audioTitleLabel)
        view.addSubview(sliderAudio)
        view.addSubview(timestackView)
        view.addSubview(ppnpStackView)
        view.addSubview(collectionView)
        
        
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.allowsMultipleSelection = false

        collectionView.register(TracksCell.self, forCellWithReuseIdentifier: cellID)
        
        
        view.addConstraint(NSLayoutConstraint(item: audioTitleLabel, attribute: .bottom, relatedBy: .equal, toItem: albumImg, attribute: .bottom, multiplier: 1, constant: 48))
        view.addConstraint(NSLayoutConstraint(item: sliderAudio, attribute: .bottom, relatedBy: .equal, toItem: audioTitleLabel, attribute: .bottom, multiplier: 1, constant: 30))
        view.addConstraint(NSLayoutConstraint(item: timestackView, attribute: .bottom, relatedBy: .equal, toItem: sliderAudio, attribute: .bottom, multiplier: 1, constant: 30))
        view.addConstraint(NSLayoutConstraint(item: ppnpStackView, attribute: .bottom, relatedBy: .equal, toItem: timestackView, attribute: .bottom, multiplier: 1, constant: 60))
        
        
        
        
        
        NSLayoutConstraint.activate([
            
            
            // albumImg
            albumImg.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            albumImg.topAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            albumImg.widthAnchor.constraint(equalToConstant: 210),
            albumImg.heightAnchor.constraint(equalToConstant: 210),
            
            // albumImg
            audioTitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            audioTitleLabel.leftAnchor.constraint(equalTo: view.leftAnchor),
            audioTitleLabel.rightAnchor.constraint(equalTo: view.rightAnchor),
            
            
            // Slider
            sliderAudio.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            sliderAudio.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            sliderAudio.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
            
            // Audio Time Indicator
            timestackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            timestackView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            timestackView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
            
            
            // Play Paused Prev Next Button
            ppnpStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            ppnpStackView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 70),
            ppnpStackView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -70),
            
            // CollectionView x,y,w,h
            collectionView.topAnchor.constraint(equalTo: ppnpStackView.safeAreaLayoutGuide.bottomAnchor, constant: 30),
            collectionView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            collectionView.widthAnchor.constraint(equalToConstant: view.frame.width - 32),
            collectionView.heightAnchor.constraint(equalToConstant: 350),
            
        
            
        ])
        
        
        
    }
    
    func formatTimeFromSeconds(totalSeconds: Int32) -> String {
        let seconds: Int32 = totalSeconds%60
        let minutes: Int32 = (totalSeconds/60)%60
        return String(format: "%02d:%02d", minutes,seconds)
    }
    
    
    

 }

let cellID = "cellID"

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tracks.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! TracksCell
        cell.backgroundColor = UIColor.init(white: 0, alpha: 0.6)
        

        let selectedIndexPath = IndexPath(item: index, section: 0)
        collectionView.selectItem(at: selectedIndexPath, animated: false, scrollPosition: [])
        
        
        let track = tracks[indexPath.row]
        cell.songTitle.text = track.title
        cell.artist.text = track.artist
        cell.durationAndsubType.text = "\(track.duration) | \(track.genere)"
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let selectedItemIndexPath: Int = indexPath.row
        let selectedIndexPath = NSIndexPath(item: selectedItemIndexPath, section: 0)
        collectionView.selectItem(at: selectedIndexPath as IndexPath, animated: true, scrollPosition: [])
        collectionView.scrollToItem(at: selectedIndexPath as IndexPath, at: .centeredVertically, animated: true)
        self.playSelectedCell(cellIndexPath: selectedItemIndexPath)
        
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: collectionView.frame.width, height: 64)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}
