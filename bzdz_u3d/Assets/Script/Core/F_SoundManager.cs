using System;
using System.Collections.Generic;
using System.Collections;
using UnityEngine;
using FairyGUI;

public class F_SoundManager : F_Singleton<F_SoundManager>
{
    public Vector3 effPoint = new Vector3(0,1,-10);
    private AudioSource m_audio;
    private Hashtable sounds = new Hashtable();
    int soundtrackCurr = 0;
    List<AudioClip> soundtrack = new List<AudioClip>();

    float _SoundMusic = 0;
    float _SoundEffect = 0;
    public void Run()
    {
        m_audio = gameObject.AddComponent<AudioSource>();
        Add("gameBg", Resources.Load<AudioClip>("gameBg"));
        //默认给到50
        SetMusicVolume((float)PlayerPrefs.GetFloat("SoundMusic3", 80) / 100);
        SetEffVolume((float)PlayerPrefs.GetFloat("SoundEffect2", 100) / 100);
        SetBackSoundTrack(new string[] { "gameBg" });
    }
    public void Add(string key, AudioClip value)
    {
        if (sounds[key] != null || value == null) return;
        sounds.Add(key, value);
    }
    public void Remove(string key)
    {
        if (sounds[key] != null) return;
        sounds.Remove(key);
    }
    AudioClip Get(string key)
    {

        if (key == null) return null;
        if (key.Length <= 0) return null;
        if (sounds.Contains(key) == false) return null;
        return sounds[key] as AudioClip;
    }


    public void PlayEffectWithVolume(string key, int volume)
    {

        if (volume == 0) return;
        AudioClip ac = Get(key);
        if (ac == null) return;
        AudioSource.PlayClipAtPoint(ac, effPoint, Convert.ToSingle(volume) / 100 * _SoundEffect);
    }
    public void PlayEffect(string key)
    {
        AudioClip ac = Get(key);
        if (ac == null) return;
        AudioSource.PlayClipAtPoint(ac, effPoint, _SoundEffect);
    }

    public void PlayEffect(string key,bool isloop)
    {
        AudioClip ac = Get(key);
        if (ac == null) return;
        m_audio.clip = ac;
        m_audio.loop = isloop;
        m_audio.Play();
    }

    public void StopPlayEffect()
    {
        m_audio.clip = null;
        m_audio.loop = false;
        m_audio.Stop();
    }

    public void SetBackSoundTrack(string[] keys)
    {

        if (keys.Length == 0) return;
        soundtrack.Clear();
        for (int i = 0; i < keys.Length; i++)
        {
            AudioClip ac = Get(keys[i]);
            if (ac != null)
            {

                soundtrack.Add(ac);
            }
        }
        if (soundtrack.Count <= 0)
        {
            Debug.Log("设置播放背景音乐列表失败.");
            return;
        }
        soundtrackCurr = 0;
        PlayNextSong();
    }
    void PlayNextSong()
    {
        if(_isOpenMusicVolume)
        {
            m_audio.clip = soundtrack[soundtrackCurr];
            soundtrackCurr = (soundtrackCurr + 1) % soundtrack.Count;
            m_audio.volume = _SoundMusic;
            m_audio.Play();
        }
        

    }
    void Update()
    {
        if (m_audio != null && m_audio.isPlaying == false)
        {
            PlayNextSong();
        }
    }


    public void SetMusicVolume(float volume)
    {
        _SoundMusic = volume;
        if (m_audio == null) return;
        m_audio.volume = volume;
    }

    bool _isOpenMusicVolume=true;
    public void OpenMusicVolume()
    {
        _isOpenMusicVolume=true;  
        if (m_audio == null) return;
        m_audio.volume = _SoundMusic; 
                
    }
    public void CloseMusicVolume()
    {
        _isOpenMusicVolume=false; 
        if (m_audio == null) return;
        m_audio.volume = 0;           
    }
    public void SetEffVolume(float volume)
    {
        GRoot.inst.soundVolume = volume;
        _SoundEffect = volume;
    }
}

