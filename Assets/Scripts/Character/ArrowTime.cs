using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ArrowTime : MonoBehaviour
{
    private CharacterControllerScript m_player;

    [SerializeField]
    private float m_slowAmount;

    [SerializeField]
    private float m_slowLength;

    private float m_timer;

    private void Awake()
    {
        m_player = gameObject.GetComponent<CharacterControllerScript>();
        m_timer = m_slowLength;
    }

    private void OnEnable()
    {
        m_player.OnBulletTime += SlowDown;
    }

    private void OnDisable()
    {
        m_player.OnBulletTime -= SlowDown;
    }

    private void Update()
    {
        if(m_timer > 0)
        {
            m_timer -= Time.unscaledDeltaTime;
        }

        if(m_timer <= 0)
        {
            SlowDown(false);
        } 
    }

    public void SlowDown(bool active)
    {
        if(active)
        {
            m_timer = m_slowLength;
            Time.timeScale = m_slowAmount;
            Time.fixedDeltaTime = Time.timeScale * 0.02f;
        }
        else
        {
            Time.timeScale = 1f;
            Time.fixedDeltaTime = 0.02f;
        }
    }
}
