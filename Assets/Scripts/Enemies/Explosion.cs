using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.VFX;

public class Explosion : MonoBehaviour
{
    [SerializeField]
    private float m_damage;
    [SerializeField]
    private float m_explosionTime = 1.0f;

    private string m_playerTag;

    private Animation m_animation;

    private VisualEffect m_vfx;

    private float m_timer;
    private float m_counterTimer;
    //private bool m_destroy;

    void Start()
    {
        m_playerTag = UtilsGyromitra.SearchForTag("Player");
        m_vfx = GetComponent<VisualEffect>();
        m_vfx.SetFloat("Size", 0.0f);
        m_timer = 0;
        m_counterTimer = 0;
    }

    void Update()
    {
        //if (m_animation.IsPlaying("Explosion"))
        //{
        //    m_destroy = true;
        //}

        //if (m_destroy)
        //{
        //    if(m_timer >= 0.3f)
        //    {
        //        Destroy(gameObject);
        //    }
        //    else
        //    {
        //        m_timer += Time.deltaTime;
        //    }
        //}

        if (m_timer >= m_explosionTime)
        {
            m_counterTimer -= Time.deltaTime;
            m_vfx.SetFloat("Size", m_counterTimer);
            
            if (m_counterTimer <= m_timer) gameObject.transform.localScale = new Vector3(m_counterTimer, m_counterTimer, m_counterTimer);
            if (m_counterTimer <= 0) Destroy(gameObject);
        }
        else
        {
            m_timer += Time.deltaTime;
            m_counterTimer = m_timer*3;
            m_vfx.SetFloat("Size", m_timer);
        }

    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag(m_playerTag))
        {
            other.GetComponent<CharacterHP>().Damage(m_damage);
        }
    }
}
