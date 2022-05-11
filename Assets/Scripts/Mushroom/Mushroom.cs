using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Mushroom : MonoBehaviour
{
    private float m_timeToDestroy = 5.0f;
    private float m_currentTime;

    [SerializeField]
    private Animation m_animation;
    [SerializeField]
    private AnimationClip m_spawnClip;

    void Update()
    {
        if (m_currentTime >= m_timeToDestroy)
        {
        
            DestroyMushroom();
            
        }
        m_currentTime += Time.deltaTime;
    }

    public void DestroyMushroom()
    {
        gameObject.SetActive(false);
        CharacterControllerScript.GetMushroomPool().m_ActiveElementsList.Remove(gameObject);
        CharacterControllerScript.GetMushroomPool().m_CurrentAmount -= 1;

        m_currentTime = 0.0f;
    }

    public void SetCurrentTime(float value)
    {
        m_currentTime = value;
    }

    public void PlayMushroomAnimation(AnimationClip l_clip)
    {
        m_animation.Play(l_clip.name);        
    }

    public void PlaySpawnAnimation()
    {
        PlayMushroomAnimation(m_spawnClip);
    }

}
